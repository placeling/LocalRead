class HomeController < ApplicationController
  def index
    @subscriber = Subscriber.new
  end

  def city
    @subscriber = Subscriber.new( :location => [params[:lat], params[:lng]], :place_json=>"{\"address_components\":[{\"long_name\":\"Vancouver\",\"short_name\":\"Vancouver\",\"types\":[\"locality\",\"political\"]}" )

    respond_to do |format|
      format.html
    end
  end

  def dead_signup

    respond_to do |format|
      format.html { render :action => "signup" }
    end
  end

  def signup
    @subscriber = Subscriber.new( :email => params[:subscriber][:email], :location => params[:subscriber][:location].split(","), :place_json => params[:subscriber][:place_json] )

    if @subscriber.save
      track! :registration
      respond_to do |format|
        format.html { redirect_to :action => "dead_signup" }
      end
    else
      respond_to do |format|
        format.html { render :action => "index" }
      end
    end

  end
end
