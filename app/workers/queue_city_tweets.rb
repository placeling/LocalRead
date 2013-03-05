class QueueCityTweets
  @queue = :twitter

  def self.perform()

    City.each do |city|
      $redis.del( city.city_queue_key )

      response = HTTParty.get("#{APP_CONFIG['chatham_location']}/recommendations/nearby.json?lat=#{city.location[0]}&lng=#{city.location[1]}")
      chatham_data = Hashie::Mash.new( response )
      bloggers = chatham_data.bloggers

      all_entries = []
      bloggers.each do |blogger|
        blogger['entries'].each do |entry|
          if (!blogger['twitter'].nil? &&blogger['twitter']!="") || (! entry.place['twitter'].nil? &&  entry.place['twitter']!="")
            all_entries << [entry['url'], blogger['title'], entry.place['name'], blogger['twitter'], entry.place['twitter']]
          end
        end
      end

      all_entries.shuffle!

      all_entries.each do |entry|
        $redis.rpush( city.city_queue_key, entry.to_json )
      end
    end

  end
end