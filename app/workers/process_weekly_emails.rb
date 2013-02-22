class ProcessWeeklyEmails
  @queue = :email

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