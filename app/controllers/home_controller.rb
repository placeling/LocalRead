class HomeController < ApplicationController
  def index
    @subscriber = Subscriber.new

  end

  def signup
    @subscriber = Subscriber.new( :email => params[:subscriber][:email] )

    if @subscriber.save
      respond_to do |format|
        format.html
      end
    else
      respond_to do |format|
        format.html { render :action => "index" }
      end
    end

  end
end
