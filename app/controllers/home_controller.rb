class HomeController < ApplicationController
  def index
    @subscriber = Subscriber.new

  end

  def dead_signup

    respond_to do |format|
      format.html { render :action => "signup" }
    end
  end

  def signup
    @subscriber = Subscriber.new( :email => params[:subscriber][:email], :loc => params[:subscriber][:location].split(",") )

    if @subscriber.save
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
