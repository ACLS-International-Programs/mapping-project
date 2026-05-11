#!/usr/bin/env ruby
# fetch_acls_news.rb
# Converts a JSON export from the ACLS WordPress REST API into acls_news.yml.
#
# USAGE
# -----
# 1. Open this URL in your browser and save the page (Cmd+S or File > Save):
#
#      https://www.acls.org/wp-json/wp/v2/news?per_page=100&page=1&_fields=id,title,link,date,excerpt,news_related_program
#
#    Repeat for pages 2, 3 … until you have all pages (check X-WP-TotalPages
#    in the Network tab, or just stop when a page returns fewer than 100 items).
#    Save each file as, e.g.:
#      src/_data/downloads/acls_news_p1.json
#      src/_data/downloads/acls_news_p2.json
#
# 2. Run:
#      bundle exec ruby src/_scripts/fetch_acls_news.rb
#
# The script reads every *.json file in src/_data/downloads/, filters for
# items tagged with term 25469 (Luce/ACLS Program in China Studies), and
# writes src/_data/acls_news.yml.
#
# NOTE: If news_related_program is not present in the JSON (field not exposed
# by the API), the script falls back to title-based keyword matching.

require 'date'
require 'yaml'
require 'json'

DOWNLOADS_DIR = File.expand_path('../../_data/downloads', __FILE__)
DATA_FILE     = File.expand_path('../../_data/acls_news.yml', __FILE__)
PROGRAM_TERM  = 25_469

CHINA_KEYWORDS = [
  /china studies/i,
  /luce.?acls/i,
  /east asia/i,
  /asian studies/i,
  /china studies digital/i,
  /xinjiang/i,
  /mapping project/i
].freeze

def decode_html(str)
  str.to_s
     .gsub('&#8217;', "’").gsub('&#8216;', "‘")
     .gsub('&#8220;', "“").gsub('&#8221;', "”")
     .gsub('&#8211;', "–").gsub('&#8212;', "—")
     .gsub('&#038;',  '&').gsub('&amp;', '&')
     .gsub('&lt;', '<').gsub('&gt;', '>').gsub('&hellip;', "…")
     .gsub('&nbsp;', ' ').gsub(/\\\//, '/').strip
end

def strip_tags(html)
  html.to_s.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
end

def china_studies?(item)
  programs = item['news_related_program']
  if programs.is_a?(Array) && !programs.empty?
    return programs.include?(PROGRAM_TERM)
  end
  # Fallback: check title and excerpt for relevant keywords
  text = "#{item.dig('title', 'rendered')} #{item.dig('excerpt', 'rendered')}"
  CHINA_KEYWORDS.any? { |kw| text.match?(kw) }
end

# ---------------------------------------------------------------------------
# Load JSON files from downloads directory
# ---------------------------------------------------------------------------

unless Dir.exist?(DOWNLOADS_DIR)
  puts "Creating downloads directory: #{DOWNLOADS_DIR}"
  Dir.mkdir(DOWNLOADS_DIR)
end

json_files = Dir.glob(File.join(DOWNLOADS_DIR, '*.json')).sort

if json_files.empty?
  puts <<~MSG

    No JSON files found in src/_data/downloads/.

    To update the news feed:

    1. Open this URL in your browser:
         https://www.acls.org/wp-json/wp/v2/news?per_page=100&page=1&_fields=id,title,link,date,excerpt,news_related_program

    2. Save the page to:
         src/_data/downloads/acls_news_p1.json

    3. Check if there are more pages — repeat for page=2, page=3 as needed
       (stop when you get fewer than 100 results).

    4. Run this script again.

  MSG
  exit 1
end

puts "Found #{json_files.length} JSON file(s) in downloads/:"
json_files.each { |f| puts "  #{File.basename(f)}" }

all_items = []
json_files.each do |path|
  raw  = File.read(path, encoding: 'UTF-8')
  data = JSON.parse(raw)
  data = [data] unless data.is_a?(Array)
  puts "  #{File.basename(path)}: #{data.length} item(s)"
  all_items += data
rescue JSON::ParserError => e
  puts "  WARNING: Could not parse #{File.basename(path)}: #{e.message} — skipping."
end

puts "Total items loaded: #{all_items.length}"

# ---------------------------------------------------------------------------
# Filter for China Studies items
# ---------------------------------------------------------------------------

matched = all_items.select { |item| china_studies?(item) }

if matched.empty?
  puts "WARNING: No items matched China Studies filter."
  puts "Saving all #{all_items.length} items as fallback (most recent first)."
  matched = all_items
end

# Sort by date descending, deduplicate by URL
matched = matched
  .sort_by { |item| item['date'].to_s }
  .reverse
  .uniq { |item| item['link'].to_s }

puts "Matched #{matched.length} item(s) after filtering and deduplication."

# ---------------------------------------------------------------------------
# Shape and write YAML
# ---------------------------------------------------------------------------

records = matched.map do |item|
  date_obj = DateTime.parse(item['date']) rescue nil
  {
    'title'   => decode_html(item.dig('title',   'rendered')),
    'url'     => decode_html(item['link'].to_s),
    'date'    => date_obj ? date_obj.strftime('%B %-d, %Y') : '',
    'excerpt' => decode_html(strip_tags(item.dig('excerpt', 'rendered').to_s))
  }
end

File.write(DATA_FILE, { 'items' => records }.to_yaml)
puts "Wrote #{records.length} item(s) to #{DATA_FILE}"
puts
puts "You can now delete the files in src/_data/downloads/ if you like."
