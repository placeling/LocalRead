require 'nokogiri'

module ApplicationHelper


  def get_entry_image( content )

    doc = Nokogiri::HTML( content )

    hosted_image = nil

    doc.css('img').each do |image|
      if !(image['width'] && image['width'].to_i < 200)

        hosted_image = HostedImage.where(:url => image['src']).first

        if hosted_image.nil?
          hosted_image = HostedImage.new(:url => image['src'])
          hosted_image.remote_image_url = image['src']
          hosted_image.save!
        end

        break
      end
    end

    if hosted_image.nil?
      return nil
    else
      return hosted_image.image_url(:thumb)
    end
  end


  def extract_snippet( content)
    strip_tags( content ).truncate(150, :separator => ' ').html_safe
  end
end
