class ShortenedUrlsController < ApplicationController

  # find the real link for the shortened link key and redirect
  def show
    # only use the leading valid characters
    token = params[:id]

    # pull the link out of the db
    sl = ShortenedUrl.find_by_token(token)

    if sl
      # don't want to wait for the increment to happen, make it snappy!
      # this is the place to enhance the metrics captured
      # for the system. You could log the request origin
      # browser type, ip address etc.
      #Thread.new do
        sl.use_count = sl.use_count + 1
        s1.save
      #  ActiveRecord::Base.connection.close
      #end
        request.env['HTTP_REFERER'] = "http://thelocalread.com"
      # do a 301 redirect to the destination url
      redirect_to sl.url, :status => :moved_permanently
    else
      # if we don't find the shortened link, redirect to the root
      # make this configurable in future versions
      redirect_to '/'
    end
  end

end
