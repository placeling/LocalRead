class Issue
  include Mongoid::Document
  include Mongoid::Timestamps


  field :content, :type => Hash
  field :location, :type => Array

  index(
      [
          [:location, Mongo::GEO2D]
      ], background: true

  )


end