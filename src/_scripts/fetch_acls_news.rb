#!/usr/bin/env ruby
# fetch_acls_news.rb
# Run manually to refresh _data/acls_news.yml from the ACLS website.
# Usage: ruby src/_scripts/fetch_acls_news.rb
# The updated _data/acls_news.yml will be picked up on the next jekyll build.

require 'net/http'
require 'uri'
require 'date'
require 'nokogiri'
require 'zlib'
require 'stringio'
require 'yaml'

PAGE_URL  = 'https://www.acls.org/acls-news/?_news_related_program=25469'
DATA_FILE = File.expand_path('../../_data/acls_news.yml', __FILE__)

puts "Fetching #{PAGE_URL}..."

begin
  uri  = URI.parse(PAGE_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl      = true
  http.read_timeout = 15
  http.open_timeout = 10

  request = Net::HTTP::Get.new(uri.request_uri)
  request['User-Agent']      = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
  request['Accept']          = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
  request['Accept-Language'] = 'en-US,en;q=0.9'
  request['Accept-Encoding'] = 'gzip, deflate, br'
  request['Connection']      = 'keep-alive'
  request['Cache-Control']   = 'no-cache'

  response = http.request(request)

  if response.code == '200'
    raw_body = response.body
    encoding = response['Content-Encoding'].to_s.downcase
    raw_body = Zlib::GzipReader.new(StringIO.new(raw_body)).read if encoding == 'gzip'

    body = raw_body.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace)
    doc  = Nokogiri::HTML(body, nil, 'UTF-8')

    articles = doc.css('article.teaser')
    puts "Found #{articles.length} article(s)"

    items = articles.map do |article|
      title_el = article.at_css('.teaser__title a')
      title    = title_el ? title_el.text.strip : nil
      url      = title_el ? title_el['href'].to_s : nil

      date_str = article.at_css('.teaser__date')&.text&.strip
      date_obj = begin
        Date.parse(date_str) if date_str
      rescue
        nil
      end

      excerpt = article.at_css('.teaser__summary')&.text&.strip.to_s

      next nil unless title && url

      {
        'title'   => title,
        'url'     => url,
        'date'    => date_obj ? date_obj.strftime('%B %-d, %Y') : (date_str || ''),
        'excerpt' => excerpt
      }
    end.compact

    if items.empty?
      puts "WARNING: Fetched successfully but parsed 0 items — data file not updated."
      exit 1
    end

    File.write(DATA_FILE, { 'items' => items }.to_yaml)
    puts "Wrote #{items.length} item(s) to #{DATA_FILE}"

  else
    puts "ERROR: HTTP #{response.code} — data file not updated."
    exit 1
  end

rescue => e
  puts "ERROR: #{e.class}: #{e.message} — data file not updated."
  exit 1
end
