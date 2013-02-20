class HostedImage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, :type => String

  mount_uploader :image, PictureUploader

  index({ url: 1 })

end