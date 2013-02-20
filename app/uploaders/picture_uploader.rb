class PictureUploader  < CarrierWave::Uploader::Base
  # To change this template use File | Settings | File Templates.

  include CarrierWave::MiniMagick

  if Rails.env.test?
    storage :file
  else
    storage :fog
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :thumb do
    process :resize_to_limit => [nil, 200]
  end

  # If don't include get strange things e.g., txt files can be uploaded and resize to > 1 GB. Kills server performance
  def extension_white_list
    %w(jpg jpeg gif png bmp)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if !Rails.env.test?
      "#{secure_token}#{File.extname(original_filename).downcase}" if original_filename
    else
      "#{secure_token}.#{file.extension}" if original_filename.present?
    end
  end

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, UUIDTools::UUID.random_create().to_s())
  end


end