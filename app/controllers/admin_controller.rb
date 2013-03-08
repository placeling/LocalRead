class AdminController < ApplicationController
  # To change this template use File | Settings | File Templates.


  def links

    @links = ShortenedUrl.order_by([:created_at, :desc]).limit(100)


    respond_to do |format|
      format.html {render layout: 'layouts/localread'}
    end
  end

end