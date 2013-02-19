require 'nokogiri'

module ApplicationHelper


  def get_entry_image( content )

    doc = Nokogiri::HTML( content )

    img = nil

    doc.css('img').each do |image|
      if !(image['width'] && image['width'].to_i < 200)
        img = image
        break
      end
    end

    return img
  end


  def extract_snippet( content)
    strip_tags( content ).truncate(150, :separator => ' ').html_safe
  end
end
