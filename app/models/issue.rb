class Issue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :content, :type => Hash
  field :location, :type => Array
  field :mailed_to, :type => Integer, :default => 0

  belongs_to :city

  slug :scope=> :city  do |cur_object|
    cur_object.created_at.to_time.strftime("%Y-%m-%d")
  end


end