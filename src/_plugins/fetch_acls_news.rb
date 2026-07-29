# fetch_acls_news.rb
#
# Automatically fetches the latest ACLS news items from the WordPress REST
# API at build time and writes them to _data/acls_news.yml. Runs on every
# `jekyll build` / `jekyll serve` via the :site, :after_init hook — no
# manual steps required. The existing acls_news.rb generator then loads
# that file into site.data as usual.
#
# BACKGROUND: acls.org was previously blocked by Cloudflare's bot protection,
# which silently dropped automated requests (confirmed blocked as of the
# site's initial build in May 2026). As of 2026-07-29, live fetches succeed
# again. Since Cloudflare rules can change at any time — and GitHub Actions'
# runner IPs may be treated differently than other traffic — this plugin is
# written to fail safely:
#
#   - If the live fetch fails for any reason (network error, timeout, bad
#     response, blocked request), it logs a warning and leaves the existing
#     _data/acls_news.yml untouched. The site still builds normally with the
#     last successfully fetched news.
#   - It never raises and never breaks the build.
#
# If live fetching breaks for an extended period, fall back to the manual
# workflow documented in src/_scripts/fetch_acls_news_manual_backup.rb.

require 'net/http'
require 'json'
require 'yaml'
require 'date'
require 'uri'

module ACLSNewsFetcher
  API_BASE     = 'https://www.acls.org/wp-json/wp/v2/news'
  PER_PAGE     = 100
  MAX_PAGES    = 10
  PROGRAM_TERM = 25_469
  TIMEOUT      = 10 # seconds
  USER_AGENT   = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ' \
                 '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'

  CHINA_KEYWORDS = [
    /china studies/i,
    /luce.?acls/i,
    /east asia/i,
    /asian studies/i,
    /china studies digital/i,
    /xinjiang/i,
    /mapping project/i
  ].freeze

  def self.decode_html(str)
    str.to_s
       .gsub('&#8217;', "’").gsub('&#8216;', "‘")
       .gsub('&#8220;', "“").gsub('&#8221;', "”")
       .gsub('&#8211;', "–").gsub('&#8212;', "—")
       .gsub('&#038;', '&').gsub('&amp;', '&')
       .gsub('&lt;', '<').gsub('&gt;', '>').gsub('&hellip;', "…")
       .gsub('&nbsp;', ' ').gsub(/\\\//, '/').strip
  end

  def self.strip_tags(html)
    html.to_s.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
  end

  def self.china_studies?(item)
    programs = item['news_related_program']
    return programs.include?(PROGRAM_TERM) if programs.is_a?(Array) && !programs.empty?

    text = "#{item.dig('title', 'rendered')} #{item.dig('excerpt', 'rendered')}"
    CHINA_KEYWORDS.any? { |kw| text.match?(kw) }
  end

  def self.fetch_page(page)
    uri = URI(
      "#{API_BASE}?per_page=#{PER_PAGE}&page=#{page}" \
      '&_fields=id,title,link,date,excerpt,news_related_program'
    )
    response = Net::HTTP.start(uri.host, uri.port,
                                use_ssl: true,
                                open_timeout: TIMEOUT,
                                read_timeout: TIMEOUT) do |http|
      http.get(uri.request_uri, { 'User-Agent' => USER_AGENT })
    end

    raise "HTTP #{response.code} on page #{page}" unless response.is_a?(Net::HTTPSuccess)

    body = response.body.to_s.strip
    raise "Empty response body on page #{page}" if body.empty?

    JSON.parse(body)
  end

  def self.fetch_all
    items = []
    (1..MAX_PAGES).each do |page|
      data = fetch_page(page)
      data = [data] unless data.is_a?(Array)
      break if data.empty?

      items.concat(data)
      break if data.length < PER_PAGE
    end
    items
  end

  def self.build_records(items)
    matched = items.select { |item| china_studies?(item) }
    matched = items if matched.empty?

    matched
      .sort_by { |item| item['date'].to_s }
      .reverse
      .uniq { |item| item['link'].to_s }
      .map do |item|
        date_obj = begin
          DateTime.parse(item['date'])
        rescue StandardError
          nil
        end
        {
          'title'   => decode_html(item.dig('title', 'rendered')),
          'url'     => decode_html(item['link'].to_s),
          'date'    => date_obj ? date_obj.strftime('%B %-d, %Y') : '',
          'excerpt' => decode_html(strip_tags(item.dig('excerpt', 'rendered').to_s))
        }
      end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  data_file = File.join(site.source, '_data', 'acls_news.yml')

  begin
    items = ACLSNewsFetcher.fetch_all
    raise 'No items returned from API' if items.empty?

    records = ACLSNewsFetcher.build_records(items)
    raise 'No records remained after filtering' if records.empty?

    File.write(data_file, { 'items' => records }.to_yaml)
    Jekyll.logger.info 'ACLS News:', "Live fetch succeeded — wrote #{records.length} item(s) to _data/acls_news.yml"
  rescue StandardError => e
    Jekyll.logger.warn 'ACLS News:', "Live fetch failed (#{e.message})."
    if File.exist?(data_file)
      Jekyll.logger.warn 'ACLS News:', 'Keeping existing _data/acls_news.yml — site will build with the last successfully fetched news.'
    else
      Jekyll.logger.warn 'ACLS News:', 'No existing _data/acls_news.yml found — news section will be empty. ' \
                                        'See src/_scripts/fetch_acls_news_manual_backup.rb for the manual fallback workflow.'
    end
  end
end
