require 'yaml'

@config  = YAML.load_file '_config.yml'
@baseurl = ENV['BASEURL'] || @config.dig('baseurl')

task :reset do
  sh "rm -rf _site .jekyll*"
end

task :build do
  sh "ruby src/_scripts/csv_to_yaml.rb"
  sh "ruby src/_scripts/generate_resources.rb"
  puts @baseurl
  sh "bundle exec jekyll build -b '#{@baseurl}'"
end