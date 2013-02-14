class Subscribers::ConfirmationsController < Devise::ConfirmationsController

  before_filter :set_redirect_location, :only => :show

  def set_redirect_location
    session["subscriber_return_to"] = confirmed_path
  end


end
