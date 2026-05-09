require 'net/http'
require 'uri'
require 'date'
require 'nokogiri'

module Jekyll
  class ACLSNewsGenerator < Generator
    safe true
    priority :high

    PAGE_URL = 'https://www.acls.org/acls-news/?_news_related_program=25469'

    def generate(site)
      Jekyll.logger.info "ACLS News:", "Fetching page #{PAGE_URL}..."

      begin
        uri = URI.parse(PAGE_URL)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 15
        http.open_timeout = 10

        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = 'Mozilla/5.0 (compatible; Jekyll build; ACLS Mapping Project)'
        request['Accept']     = 'text/html,application/xhtml+xml'

        response = http.request(request)

        if response.code == '200'
          # Force UTF-8 to avoid ArgumentError from ambiguous charset declarations
          body = response.body.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace)
          doc = Nokogiri::HTML(body, nil, 'UTF-8')

          # WordPress typically wraps each post in an <article> element
          articles = doc.css('article.teaser')
          Jekyll.logger.info "ACLS News:", "Found #{articles.length} article element(s)"

          items = articles.map do |article|
            # Title and link
            title_el = article.at_css('.teaser__title a')
            title = title_el ? title_el.text.strip : nil
            url   = title_el ? title_el['href'].to_s : nil

            # Date — plain text like "April 7, 2026"
            date_str = article.at_css('.teaser__date')&.text&.strip
            date_obj = begin
              Date.parse(date_str) if date_str
            rescue
              nil
            end

            # Excerpt
            excerpt = article.at_css('.teaser__summary')&.text&.strip.to_s

            next nil unless title && url

            {
              'title'   => title,
              'url'     => url,
              'date'    => date_obj ? date_obj.strftime('%B %-d, %Y') : (date_str || ''),
              'excerpt' => excerpt
            }
          end.compact

          Jekyll.logger.info "ACLS News:", "Parsed #{items.length} item(s)"
          site.data['acls_news'] = { 'items' => items, 'error' => nil }

        else
          Jekyll.logger.warn "ACLS News:", "Page returned HTTP #{response.code} — news section will be empty"
          site.data['acls_news'] = { 'items' => [], 'error' => "HTTP #{response.code}" }
        end

      rescue => e
        Jekyll.logger.warn "ACLS News:", "Fetch failed (#{e.class}: #{e.message}) — news section will be empty"
        site.data['acls_news'] = { 'items' => [], 'error' => e.message }
      end
    end
  end
end
