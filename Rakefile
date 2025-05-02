require 'html-proofer'
require 'yaml'

@config  = YAML.load_file '_config.yml'
@baseurl = ENV['BASEURL'] || @config.dig('baseurl')

desc "build the site with baseurl for testing and deployment"
task :build do
  sh "bundle exec jekyll clean && bundle exec jekyll build -b '#{@baseurl}'"
end


namespace :test do 
  namespace :links do
    desc "Test internal links"
    task :internal do 
      opts = { 
        disable_external: true, 
        enforce_https: false,
        checks: ['Links'] 
      }
      HTMLProofer.check_directory('./_site', opts).run
    end 

    desc "Test external links"
    task :external do 
      opts = { 
        ignore_urls: ['^.*localhost:\d*$'],
        check_external_hash: false,
        check_internal_hash: false,
        checks: ['Links'] 
      }
      HTMLProofer.check_directory('./_site', opts).run
    end 

    desc 'Test all links'
    task :all do 
      Rake::Task["test:links:internal"].invoke
      Rake::Task["test:links:external"].invoke
    end
  end

  task :html do 
    # to do
  end 

  task :a11y do 
    # to do
  end 

  task :all do 
    Rake::Task["test:links"].execute  
  end
end




# namespace :site do
#   desc 'run html and internal link checks'
#   task :test do
#     Rake::Task["site:reset"].invoke
#     Rake::Task["site:build:test"].invoke
#     opts = {
#       disable_external: false,
#       ignore_urls: [/^(?!https*:\/\/nyu-dh.github.io\/website-media).*$/]
#     }
#     HTMLProofer.check_directory('./_site', opts).run
#   end

#   desc 'run external link checks'
#   namespace :test do 
#     task :linkrot do 
#       Rake::Task["site:reset"].invoke
#       Rake::Task["site:build:test"].invoke
#       opts = {
#         ignore_status_codes: [0, 500],
#         check_external_hash: false,
#         typhoeus: {
#           followlocation: true,
#           connecttimeout: 20,
#           timeout: 40,
#         }
#       }
#       HTMLProofer.check_directory('./_site', opts).run
#       exit 1
#     end
#   end
# end