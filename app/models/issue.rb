class Issue
  include Mongoid::Document
  include Mongoid::Timestamps


  field :content, :type => Hash
  field :location, :type => Array
  field :mailed_to, :type => Integer, :default => 0

  index location: "2d"


end