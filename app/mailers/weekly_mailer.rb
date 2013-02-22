require 'json'
require 'hashie'
require 'httparty'
require 'shorten_url_interceptor'

class WeeklyMailer < ActionMailer::Base
  default from: "The Local Read <no-reply@thelocalread.com>"
  add_template_helper(ApplicationHelper)
  include Resque::Mailer
  #register_interceptor Shortener::ShortenUrlInterceptor.new


  def grab_instagrams_for( subscriber )

    @instagrams_raw = $redis.get( subscriber.location_cache_key )
    if @instagrams_raw.nil?
      begin
        instagrams = Instagram.media_search( subscriber.location[0], subscriber.location[1], {:distance => 5000, :max_timestamp => 1.day.ago.to_i, :min_timestamp => 1.week.ago.to_i, :count => 40 } ).data

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

        $redis.setex( subscriber.location_cache_key, 60*60*24, placed_instagrams.to_json )
      rescue
        placed_instagrams = nil
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

  def grab_place_data_for( subscriber )

    chatham_data_raw = $redis.get( "chathamdata" + subscriber.location_cache_key )
    chatham_data = nil
    if chatham_data_raw.nil?
      response = HTTParty.get("#{APP_CONFIG['chatham_location']}/recommendations/nearby.json?lat=#{@subscriber.location[0]}&lng=#{@subscriber.location[1]}")
      chatham_data = response

      instagrams = grab_instagrams_for( @subscriber )

      chatham_data['instagrams'] = []

      if !instagrams.nil?
        instagrams.first( 8 ).each do |hashie|
          chatham_data['instagrams'] << hashie.to_hash
        end
      end

      $redis.setex( "chathamdata"+subscriber.location_cache_key, 60*60*12, response.to_json )

      Issue.create( location: subscriber.location, content: chatham_data)

    else
      chatham_data = JSON.parse( chatham_data_raw )
    end


    return chatham_data
  end



  def thelocal( subscriber_id )
    @subscriber = Subscriber.find(subscriber_id)

    @chatham_data = grab_place_data_for( @subscriber )


    use_vanity_mailer nil
    mail(:to => @subscriber.email, :subject => "This Week's Most Interesting Places In #{@subscriber.city}") do |format|
      format.text { render 'thelocal' }
      format.html { render 'thelocal' }
    end
  end



  class Preview < MailView

    def thelocal
      user = Subscriber.where(:location.ne => nil).first
      WeeklyMailer.thelocal( user.id )
    end

  end

end
