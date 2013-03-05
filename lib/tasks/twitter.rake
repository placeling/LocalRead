require "#{Rails.root}/app/helpers/application_helper"

namespace "twitter" do
  include ApplicationHelper

  desc "Checks queues and posts message for each city twitter "
  task :post => :environment do

    City.each do |city|
      if city.twitter_access_token
        entry = $redis.lpop( city.city_queue_key )

        unless entry.nil?
          entry = JSON.parse( entry )
          twitter_client = Twitter::Client.new(
              :oauth_token => city.twitter_access_token,
              :oauth_token_secret => city.twitter_access_secret
          )


          blogger = nil
          if false #!entry[3].nil? && entry[3] != ""
            blogger = entry[3]
          else
            blogger = entry[1]
          end

          placename = nil
          if false #!entry[4].nil? && entry[4] != ""
            placename = entry[4]
          else
            placename = entry[2]
          end

          link = short_url( entry[0] )

          text = "#{blogger} wrote about #{placename}: #{link}"

          twitter_client.update( text )
        end

      end
    end

  end


end
