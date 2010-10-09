desc "Update the database with latest tweets from Twitter"
task :update => :environment do
  Importer.update
end

desc "Load the app"
task :environment do
  require 'nid'
end
