require 'nokogiri'

module ApplicationHelper

  def self.get_hostname
    if ActionMailer::Base.default_url_options[:port] && ActionMailer::Base.default_url_options[:port].to_s != "80"
      "#{ActionMailer::Base.default_url_options[:host]}:#{ActionMailer::Base.default_url_options[:port]}"
    else
      "#{ActionMailer::Base.default_url_options[:host]}"
    end
  end

  def self.short_url(url, twitter=false)
    short_url = ShortenedUrl.generate(url, twitter)
    short_url ? Rails.application.routes.url_helpers.shortener_path(:id => short_url.token, :host => self.get_hostname, :only_path => false ) : url
  end

  # generate a url from a url string
  def short_url(url, twitter=false)
    ApplicationHelper.short_url( url, twitter )
  end

  def tweet_link( issue_url, cityname )
    text = CGI.escape("Check out this week's issue of The Local Read for #{cityname}: #{issue_url}")
    url = CGI.escape( issue_url )

    return "https://twitter.com/intent/tweet?text=#{text}&related=thelocalread"
  end

  def get_entry_image( content )

    doc = Nokogiri::HTML( content )

    hosted_image = nil

    doc.css('img').each do |image|
      uri = URI(image['src'])

      if uri.host == "www.urbanspoon.com"
        next #special case, these give 403 errors
      end

      if !(image['width'] && image['width'].to_i < 200)

        hosted_image = HostedImage.where(:url => image['src']).first

        if hosted_image.nil?
          hosted_image = HostedImage.new(:url => image['src'])
          hosted_image.remote_image_url = image['src']
          if hosted_image.save
            break
          end
        end
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
