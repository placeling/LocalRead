class ShortenedUrl
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  field :url, type: String
  field :use_count, type: Integer, default: 0
  field :twitter, type: Boolean, default: false

  index ({url:1})

  token :length => 5

  URL_PROTOCOL_HTTP = "http://"
  REGEX_LINK_HAS_PROTOCOL = Regexp.new('\Ahttp:\/\/|\Ahttps:\/\/', Regexp::IGNORECASE)

  validates :url, :presence => true

  # ensure the url starts with it protocol and is normalized
  def self.clean_url(url)
    return nil if url.blank?
    url = URL_PROTOCOL_HTTP + url.strip unless url =~ REGEX_LINK_HAS_PROTOCOL
    URI.parse(url).normalize.to_s
  end

  # generate a shortened link from a url
  # link to a user if one specified
  # throw an exception if anything goes wrong
  def self.generate!(orig_url, twitter=false)
    # if we get a shortened_url object with a different owner, generate
    # new one for the new owner. Otherwise return same object

    # don't want to generate the link if it has already been generated
    # so check the datastore
    cleaned_url = clean_url(orig_url)
    scope =  self
    if surl = scope.find_or_create_by(url: cleaned_url, twitter:twitter)
      return surl
    else
      return scope.create!(url: cleaned_url, twitter:twitter)
    end
  end

  # return shortened url on success, nil on failure
  def self.generate(orig_url, owner=nil)
    begin
      generate!(orig_url, owner)
    rescue
      nil
    end
  end

end
