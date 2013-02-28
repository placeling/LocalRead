class Issue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :content, :type => Hash
  field :location, :type => Array
  field :mailed_to, :type => Integer, :default => 0

  belongs_to :city

  slug :scope=> :city  do |cur_object|
    if cur_object.created_at
      cur_object.created_at.strftime("%Y-%m-%d")
    else
      Time.now.strftime("%Y-%m-%d")
    end
  end


end