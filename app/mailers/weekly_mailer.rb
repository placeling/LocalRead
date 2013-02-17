require 'json'
require 'hashie'

class WeeklyMailer < ActionMailer::Base
  default from: "no-reply@thelocalread.com"
  include Resque::Mailer


  def grab_instagrams_for( subscriber )
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
  end



  def thelocal( subscriber_id )
    @subscriber = Subscriber.find(subscriber_id)

    @instagrams_raw = $redis.get( @subscriber.location_cache_key )
    if @instagrams_raw.nil?
      @instagrams = grab_instagrams_for( @subscriber )
    else
      @instagrams = []
      JSON.parse( @instagrams_raw ).each do |instagram|
        @instagrams << Hashie::Mash.new( instagram )
      end
    end

    @instagrams = @instagrams.slice( 6, 4 )

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
