class IssuesController < ApplicationController

  def show
    @city = City.forgiving_find( params[:city_id] )

    if @city.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    @issue = @city.issues.find params[:id]
    if @issue.nil?
      raise ActionController::RoutingError.new('Not Found')
    end

    respond_to do |format|
      format.html {render layout: 'layouts/localread'}
    end

  end

end
