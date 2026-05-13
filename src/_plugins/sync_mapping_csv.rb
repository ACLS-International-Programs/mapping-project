require 'fileutils'

Jekyll::Hooks.register :site, :after_init do |site|
  src  = File.join(site.source, '_data', 'mapping-project.csv')
  dest = File.join(site.source, 'assets', 'files', 'mapping-project.csv')

  if File.exist?(src)
    FileUtils.mkdir_p(File.dirname(dest))
    FileUtils.cp(src, dest)
    Jekyll.logger.info "Sync CSV:", "Copied _data/mapping-project.csv → assets/files/mapping-project.csv"
  else
    Jekyll.logger.warn "Sync CSV:", "_data/mapping-project.csv not found — skipping copy"
  end
end
