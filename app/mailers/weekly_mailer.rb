require 'json'
require 'hashie'
require 'httparty'

class WeeklyMailer < ActionMailer::Base
  default from: "no-reply@thelocalread.com"
  add_template_helper(ApplicationHelper)
  include Resque::Mailer


  def grab_instagrams_for( subscriber )

    @instagrams_raw = $redis.get( subscriber.location_cache_key )
    if @instagrams_raw.nil?
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

      return placed_instagrams
    else
      instagrams = []
      JSON.parse( @instagrams_raw ).each do |instagram|
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

      $redis.setex( "chathamdata"+subscriber.location_cache_key, 60*2, response.to_json )
      chatham_data = response
    else
      chatham_data = JSON.parse( chatham_data_raw )
    end

    @instagrams = grab_instagrams_for( @subscriber )

    @instagrams = @instagrams.first( 8 )

    return chatham_data
  end



  def thelocal( subscriber_id )
    @subscriber = Subscriber.find(subscriber_id)

    @chatham_data = grab_place_data_for( @subscriber )


    use_vanity_mailer nil
    mail(:to => @subscriber.email, :subject => "The Local Read for #{@subscriber.city}") do |format|
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
