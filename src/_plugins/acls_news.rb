require 'yaml'

module Jekyll
  class ACLSNewsGenerator < Generator
    safe true
    priority :high

    DATA_FILE = File.expand_path('../../_data/acls_news.yml', __FILE__)

    def generate(site)
      if File.exist?(DATA_FILE)
        data = YAML.load_file(DATA_FILE) || {}
        items = data['items'] || []
        Jekyll.logger.info "ACLS News:", "Loaded #{items.length} item(s) from _data/acls_news.yml"
        site.data['acls_news'] = { 'items' => items, 'error' => nil }
      else
        Jekyll.logger.warn "ACLS News:", "No _data/acls_news.yml found — news section will be empty"
        site.data['acls_news'] = { 'items' => [], 'error' => 'data file missing' }
      end
    end
  end
end
