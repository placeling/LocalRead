
namespace "db" do

  task :reload => [:drop, :download_and_install]

  desc "Drops the database for mongodb"
  task :drop do
    if (Rails.env == "production")
      raise "FUCK OFF, you're trying to reset the database in production"
      return
    end

    puts "DROPPING MONGO DATABASE NAMED #{ Mongoid.default_session }"
    Mongoid.default_session.drop

  end

  desc "Reloads the database based the the latest backup from production"
  task :download_and_install do
    if (Rails.env == "production")
      raise "FUCK OFF, you're trying to reset the database in production"
      return
    end

    if File.exists?('/tmp/mongodb-localread-latest.tgz')
      file = File.new('/tmp/mongodb-localread-latest.tgz', 'r')
      puts "current file in temp is timestamp: " + file.mtime.to_s
    end

    if file.nil? or file.mtime < 1.day.ago
      puts "getting new backup"
      puts `scp -P 11235 ubuntu@beagle.placeling.com:/localread_backups/latest/mongodb-latest.tgz /tmp/mongodb-localread-latest.tgz`
      puts `rm -rf /tmp/MONGOLOCALREADBACKUP`
      puts `mkdir /tmp/MONGOLOCALREADBACKUP`
      puts `tar -C /tmp/MONGOLOCALREADBACKUP -xzvf /tmp/mongodb-localread-latest.tgz`
    end

    # this is a little hacky, but works for now
    puts `mongorestore -h localhost -d local_read_development /tmp/MONGOLOCALREADBACKUP/*/local_read_production/`
    Rake::Task["db:mongoid:create_indexes"].invoke
  end
end
