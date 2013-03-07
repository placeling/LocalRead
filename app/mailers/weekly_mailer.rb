require 'shorten_url_interceptor'

class WeeklyMailer < ActionMailer::Base
  default from: "The Local Read <contact@placeling.com>"
  add_template_helper(ApplicationHelper)
  include Resque::Mailer


  def thelocal( subscriber_id, issue_id )
    @subscriber = Subscriber.find(subscriber_id)
    @issue = Issue.find( issue_id )
    @chatham_data = @issue.content #grab_place_data_for( @subscriber )

    use_vanity_mailer nil
    mail(:to => @subscriber.email, :subject => "This Week's Most Interesting Places In #{@subscriber.city}") do |format|
      format.text { render 'thelocal' }
      format.html { render 'thelocal' }
    end
  end



  class Preview < MailView

    def thelocal
      user = Subscriber.where(:location.ne => nil).first

      city = City.first

      issue = Issue.where(:city => city, :created_at.gt =>6.days.ago).first

      if issue.nil?
        contents = ProcessWeeklyEmails.issueCreator( city )
        issue = Issue.create!( :content => contents, :city => city)
      end

      WeeklyMailer.thelocal( user.id, issue.id )
    end

  end

end
