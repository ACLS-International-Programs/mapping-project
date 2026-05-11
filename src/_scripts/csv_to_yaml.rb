#!/usr/bin/env ruby
# csv_to_yaml.rb
# Converts the Airtable library-access CSV export to a clean YAML data file,
# stripping any UTF-8 BOM that Airtable adds to the first column.
#
# Usage: ruby src/_scripts/csv_to_yaml.rb
# Run this after dropping a fresh CSV export into src/_data/library-access.csv.
# The updated src/_data/library_access.yml will be picked up on the next jekyll build.

require 'csv'
require 'yaml'

CSV_FILE  = File.expand_path('../../_data/library-access.csv', __FILE__)
YAML_FILE = File.expand_path('../../_data/library_access.yml', __FILE__)

unless File.exist?(CSV_FILE)
  puts "ERROR: #{CSV_FILE} not found."
  exit 1
end

# Read raw bytes and strip UTF-8 BOM (\xEF\xBB\xBF) if present
raw = File.binread(CSV_FILE)
raw = raw.sub("\xEF\xBB\xBF".b, ''.b)
content = raw.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace)

rows = CSV.parse(content, headers: true)

if rows.empty?
  puts "ERROR: CSV parsed 0 rows — YAML not updated."
  exit 1
end

puts "Read #{rows.length} row(s) from #{CSV_FILE}"
puts "Columns: #{rows.headers.join(', ')}"

records = rows.map do |row|
  h = row.to_h
  # Blank out nil values and strip whitespace first
  h.transform_values! { |v| v.nil? ? '' : v.strip }
  # Normalise travel grant: Airtable exports checkboxes as 'checked' or ''
  h['travelgrant'] = (h['travelgrant'].downcase == 'checked')
  h
end

File.write(YAML_FILE, records.to_yaml)
puts "Wrote #{records.length} record(s) to #{YAML_FILE}"
