
class PopulateCityIssueModels < Mongoid::Migration
  def self.up
    city = City.create!(:name =>"Vancouver", :location => [49.261226, -123.1139268], :twitter_username=>"thelocalread", :subreddit=>"/r/vancouver")
    Issue.all.each do |issue|
      issue.city = city
      issue.save
    end

  end

  def self.down

  end
end