class QueueCityTweets
  @queue = :twitter

  def self.perform()

    City.each do |city|
      #$redis.del( city.city_queue_key )

      response = HTTParty.get("#{APP_CONFIG['chatham_location']}/recommendations/nearby.json?lat=#{city.location[0]}&lng=#{city.location[1]}&since=#{city.twitter_most_recent.to_time.to_i+1}")
      chatham_data = Hashie::Mash.new( response )
      bloggers = chatham_data.bloggers

      all_entries = []
      latest = Time.at( 0 )
      bloggers.each do |blogger|
        blogger['entries'].each do |entry|
          if (!blogger['twitter'].nil? &&blogger['twitter']!="") || (! entry.place['twitter'].nil? &&  entry.place['twitter']!="")
            created_at = DateTime.iso8601( entry['created_at'] )
            if latest < created_at
              latest = created_at
            end
            all_entries << [entry['url'], blogger['title'], entry.place['name'], blogger['twitter'], entry.place['twitter'], entry['title']]
          end
        end
      end

      if latest > city.twitter_most_recent
        city.twitter_most_recent = latest
        city.save
        puts latest
      end
      all_entries.shuffle!

      all_entries.sort_by!{|entry|
        if (!entry[4].nil? &&  entry[4] !="")
          1
        else
          0
        end
      }

      all_entries.each do |entry|
        puts entry
        $redis.lpush( city.city_queue_key, entry.to_json )
      end
    end

  end
end