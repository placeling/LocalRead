class CanvasController < ApplicationController
  def index

    if params['error'] == "access_denied"
      redirect_to '/'
    else

      if params['signed_request']
        @oauth = Koala::Facebook::OAuth.new(APP_CONFIG['facebook_app_id'], APP_CONFIG['facebook_app_secret'], "/auth/facebook/callback")

        @info = @oauth.parse_signed_request( params['signed_request'] )

        graph = Koala::Facebook::API.new( @info['oauth_token'] )
        profile = graph.get_object("me")
        email = profile['email']

      end

      respond_to do |format|
        format.html {render layout: 'layouts/canvas'}
      end
    end

  end

  def invite

    @invite = true

    respond_to do |format|
      format.html {render action: 'index', layout: 'layouts/canvas'}
    end
  end

end
