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

        @subscriber = Subscriber.where(:email => email).first

        if !@subscriber.nil?
          @invite = true
        else
          @subscriber = Subscriber.new( :email => email, :location => [49.261226, -123.1139268], :facebook_json => profile.to_json, :place_json=>"{\"address_components\":[{\"long_name\":\"Vancouver\",\"short_name\":\"Vancouver\",\"types\":[\"locality\",\"political\"]}" )
        end
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
