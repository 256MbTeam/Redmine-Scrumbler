namespace :scrumbler do
  namespace :assets do
    desc "Clears javascripts, stylesheets and images cache"
    task :refresh => :environment do
      scrumbler_plugin = Engines.plugins.find {|s| s.name == "redmine_scrumbler"}
      Engines::Assets.mirror_files_for scrumbler_plugin
    end
  end
end