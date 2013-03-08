class City
  include Mongoid::Document
  include Mongoid::Slug

  field :name, :type => String
  field :location, :type => Array
  field :twitter_username, :type => String
  field :twitter_access_token, :type => String
  field :twitter_access_secret, :type => String
  field :twitter_most_recent, :type => DateTime, :default => 3.days.ago

  field :tweeted_links, type: Array, default: []

  field :subreddit, :type => String
  field :featured_blogger_ids, :type => Array, :default => []

  slug :name, :index => true

  has_many :issues

  index({ location: "2d" }, { min: -200, max: 200 })

  validates_presence_of :name
  validates_presence_of :location


  def self.forgiving_find( city_id    )
    City.find( city_id )
  end

  def location_cache_key
    "#{self.location[0].to_f.round(3)},#{self.location[1].to_f.round(3)}"
  end

  def city_queue_key
    "#{self.slug}_tweetqueue"
  end

end