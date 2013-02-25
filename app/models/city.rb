class City
  include Mongoid::Document
  include Mongoid::Slug

  field :name, :type => String
  field :location, :type => Array
  field :twitter_username, :type => String
  field :subreddit, :type => String

  slug :name, :index => true

  has_many :issues

  index({ location: "2d" }, { min: -200, max: 200 })

  validates_presence_of :name
  validates_presence_of :location


  def self.forgiving_find( city_id    )
    City.find( city_id )
  end

end