#!/usr/bin/env ruby
# generate_resources.rb
# Regenerates all _resources/*.md stubs from mapping-project.csv.
#
# Run from the project root:
#   ruby src/_scripts/generate_resources.rb
#
# This script:
#   1. Reads src/_data/mapping-project.csv
#   2. Deletes all existing src/_resources/*.md files
#   3. Writes a fresh .md stub for each CSV row, with tags as a YAML list

require 'csv'
require 'yaml'
require 'fileutils'
require 'set'

CSV_FILE       = File.expand_path('../../_data/mapping-project.csv', __FILE__)
RESOURCES_DIR  = File.expand_path('../../_resources', __FILE__)

# ── Sanity checks ────────────────────────────────────────────────────────────

unless File.exist?(CSV_FILE)
  puts "ERROR: #{CSV_FILE} not found."
  exit 1
end

FileUtils.mkdir_p(RESOURCES_DIR)

# ── Read CSV ─────────────────────────────────────────────────────────────────

raw = File.binread(CSV_FILE)
raw = raw.sub("\xEF\xBB\xBF".b, ''.b)   # strip UTF-8 BOM if present
content = raw.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace)

rows = CSV.parse(content, headers: true)

if rows.empty?
  puts "ERROR: CSV parsed 0 rows — aborting."
  exit 1
end

puts "Read #{rows.length} row(s) from #{CSV_FILE}"

# ── Identify existing stubs ──────────────────────────────────────────────────

existing_ids = Dir.glob(File.join(RESOURCES_DIR, '*.md'))
                   .map { |f| File.basename(f, '.md') }
                   .to_set

# ── Generate new stubs ───────────────────────────────────────────────────────

generated = 0
updated   = 0
skipped   = 0
csv_ids   = Set.new

rows.each do |row|
  objectid = row['objectid']&.strip

  if objectid.nil? || objectid.empty?
    puts "  WARNING: skipping row with blank objectid"
    skipped += 1
    next
  end

  csv_ids.add(objectid)

  # Parse tags: comma-separated string → Ruby array (nil/blank → empty array)
  raw_tags = row['tags']&.strip || ''
  tags = raw_tags.empty? ? [] : raw_tags.split(',').map(&:strip).reject(&:empty?)

  front_matter = {
    'objectid'       => objectid.to_i,
    'title'          => row['title']&.strip || '',
    'alternatetitle' => row['alternatetitle']&.strip || '',
    'category'       => row['category']&.strip || '',
    'externalurl'    => row['externalurl']&.strip || '',
    'institution'    => row['institution']&.strip || '',
    'access'         => row['access']&.strip || '',
    'sourcelist'     => row['sourcelist']&.strip || '',
    'tags'           => tags,
    'description'    => row['description']&.strip || '',
    'lastmodified'   => row['lastmodified']&.strip || '',
    'layout'         => 'resource',
  }

  stub_path = File.join(RESOURCES_DIR, "#{objectid}.md")
  is_new = !existing_ids.include?(objectid)
  File.write(stub_path, "#{front_matter.to_yaml}---\n")
  is_new ? generated += 1 : updated += 1
end

puts "Created #{generated} new stub(s), updated #{updated} existing stub(s)"
puts "Skipped #{skipped} row(s) with blank objectid" if skipped > 0

# Report stale stubs (in _resources/ but not in CSV)
stale = existing_ids - csv_ids
unless stale.empty?
  puts "\nSTALE STUBS (no longer in CSV — safe to delete manually):"
  stale.sort_by(&:to_i).each { |id| puts "  src/_resources/#{id}.md" }
  puts "  Total stale: #{stale.size}"
end

puts "\nDone."
