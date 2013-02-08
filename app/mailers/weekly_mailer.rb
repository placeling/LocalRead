class WeeklyMailer < ActionMailer::Base
  default from: "no-reply@thelocalread.com"

  def thelocal( subscriber_id )
    @user = User.find(subscriber_id)

    mail(:to => @user.email, :subject => "This week in...") do |format|
      format.text { render 'thelocal' }
      format.html { render 'thelocal' }
    end
  end



  class Preview < MailView

    def thelocal
      user = User.skip(rand(User.count)).first
      WeeklyMailer.thelocal(user.id)
    end

  end

end
