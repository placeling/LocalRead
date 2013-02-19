class ProcessWeeklyEmails
  @queue = :email

  def self.perform()

    if Rails.env.production?
      Subscriber.where(:loc => {"$near" => [49.263548,-123.114166] , '$maxDistance' =>1}).each do |subscriber|
        if subscriber.weekly_email? && !subscriber.loc.nil? && subscriber.loc != [0.0, 0.0]
          mail =  WeeklyMailer.thelocal( subscriber.id )
          #mail.deliver
        end
      end
    else
      Subscriber.where(:loc => {"$near" => [49.263548,-123.114166] , '$maxDistance' =>1}).limit(3).each do |subscriber|
        if subscriber.weekly_email? && !subscriber.loc.nil? && subscriber.loc != [0.0, 0.0]
          mail = WeeklyMailer.thelocal( subscriber.id )
          #mail.deliver unless mail.to == nil don't actually deliver by default
        elsif subscriber.weekly_email?
          puts "skip #{user.username} because loc= #{subscriber.loc}"
        end
      end
    end

  end
end