require 'json'
require 'hashie'
require 'httparty'

class ProcessWeeklyEmails
  @queue = :email

  def self.issueCreator( city )

    response = HTTParty.get("#{APP_CONFIG['chatham_location']}/recommendations/nearby.json?lat=#{city.location[0]}&lng=#{city.location[1]}")
    chatham_data = Hashie::Mash.new( response )
    bloggers = chatham_data.bloggers
    potential_featured = []
    named_bloggers = []

    bloggers.each do |blogger|
      if blogger.entries.count >= 3
        potential_featured << blogger
      end
    end

    featured_blogger = potential_featured.shuffle.first
    named_bloggers << featured_blogger.id
    bloggers.delete( featured_blogger )
    city.featured_blogger_ids << featured_blogger.id

    places = {}
    bloggers.each do |blogger|
      blogger['entries'].each do |entry|
        entry.blogger = blogger
        if places.has_key? entry.place_id
          places[entry.place_id] << entry
        else
          places[entry.place_id] = [entry]
        end
      end
    end

    #places.sort_by! { |place| -place.entries.count }

    popular_places = []
    river = []

    #first pass, get newly created places
    #TODO: "user created" in past week
    places.each do |key, value|
      place = value.first.place
      if value.count > 1 && place.place_type == "USER_CREATED"
        place.entries = value
        popular_places << place
        places.delete( key )
      end
    end

    unless popular_places.count >= 2
      #second pass, get places written about by 3 bloggers
      #TODO: -If possible, avoid repeating the same bloggers amongst any featured places
      places.each do |key, value|
        place = value.first.place
        if value.count > 2
          place.entries = value
          popular_places << place
          places.delete( key )
        end
      end
    end

    unless popular_places.count >= 2
      #third pass, get places written about by 2 bloggers
      places.each do |key, value|
        if popular_places.count > 2
          break #prevent it from sucking up too many
        end
        place = value.first.place
        if value.count > 1
          place.entries = value
          popular_places << place
          places.delete( key )
        end
      end
    end

    popular_places = popular_places.first(2)

    popular_places.each do |place|
      named_bloggers << place['entries'].first['blogger']['_id']
      place['entries'].shuffle!
    end

    theme = nil

    #make the river
    river = []
    places.each do |place|
      if river.count > 9
        break
      end
      entry = place[1].first

      if !named_bloggers.include?( entry['blogger']['_id'] )
        river << entry
        named_bloggers << entry['blogger']['_id']
      end
    end

    instagrams = self.grab_instagrams_for( city )

    return {places: popular_places, featured: featured_blogger, river: river, theme: theme, instagrams: instagrams.first(8)}

  end



  def self.grab_instagrams_for( city )

    @instagrams_raw = $redis.get( city.location_cache_key)
    if @instagrams_raw.nil?
      instagrams = Instagram.media_search( city.location[0], city.location[1], {:distance => 5000, :max_timestamp => 1.day.ago.to_i, :min_timestamp => 1.week.ago.to_i, :count => 40 } ).data

      5.times do
        if instagrams.last.created_time.to_i < 1.week.ago.to_i
          break
        end

        begin
          instagrams.concat( Instagram.media_search( subscriber.location[0], subscriber.location[1], {:distance => 5000, :max_timestamp => instagrams.last.created_time.to_i, :min_timestamp => 1.week.ago.to_i, :count => 40 } ).data )
        rescue Exception => e
          Rails.logger.info( e )
        end

      end

      instagrams.sort_by!{|instagram| instagram.likes['count'] }
      instagrams.reverse!

      placed_instagrams = []
      instagrams.each do |instagram|
        if !instagram.location.name.nil? && !placed_instagrams.include?( instagram )
          placed_instagrams << instagram
        end
      end

      if placed_instagrams.count > 4
        $redis.setex( city.location_cache_key, 60*60*24, placed_instagrams.to_json )
      end

      return placed_instagrams
    else
      instagrams = []
      begin
        parsed_json = JSON.parse( @instagrams_raw )
      rescue
        return nil
      end

      parsed_json.each do |instagram|
        instagrams << Hashie::Mash.new( instagram )
      end

      return instagrams
    end
  end


  def self.perform()

    if Rails.env.production?
      Subscriber.where(:location => {"$near" => [49.263548,-123.114166] , '$maxDistance' =>1}).each do |subscriber|
        if subscriber.weekly_email?
          WeeklyMailer.thelocal( subscriber.id ).deliver
        end
      end
    else
      Subscriber.near(location: [49.263548,-123.114166]).each do |subscriber|
        if subscriber.weekly_email?
          puts subscriber.email
          WeeklyMailer.thelocal( subscriber.id )
        end
      end
    end

  end
end