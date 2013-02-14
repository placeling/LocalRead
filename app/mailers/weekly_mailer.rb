require 'JSON'

class WeeklyMailer < ActionMailer::Base
  default from: "no-reply@thelocalread.com"
  include Resque::Mailer


  def grab_instagrams_for( subscriber )
    instagrams = Instagram.media_search( subscriber.location[0], subscriber.location[1], {:distance => 5000, :max_timestamp => 1.day.ago.to_i, :min_timestamp => 1.week.ago.to_i, :count => 40 } ).data

    5.times do
      if instagrams.last.created_time.to_i < 1.week.ago.to_i
        break
      end

      instagrams.concat( Instagram.media_search( subscriber.location[0], subscriber.location[1], {:distance => 5000, :max_timestamp => instagrams.last.created_time.to_i, :min_timestamp => 1.week.ago.to_i, :count => 40 } ).data )
    end

    instagrams.sort_by!{|instagram| instagram.likes['count'] }
    instagrams.reverse!

    placed_instagrams = []
    instagrams.each do |instagram|
      if !instagram.location.name.nil?
        placed_instagrams << instagram
      end
    end

    $redis.setex( subscriber.location_cache_key, 60*10, placed_instagrams.to_json )

    return placed_instagrams
  end



  def thelocal( subscriber_id )
    @subscriber = Subscriber.find(subscriber_id)

    @instagrams_raw = $redis.get( @subscriber.location_cache_key )
    if @instagrams_raw.nil?
      @instagrams = grab_instagrams_for( @subscriber )
    else
      @instagrams = Json.parse( @instagrams )
    end

    mail(:to => @subscriber.email, :subject => "The Local Read for #{Time.now.strftime("%B %d, %Y")}") do |format|
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
