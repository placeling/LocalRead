class IssuesController < ApplicationController

  def show
    @city = City.forgiving_find( params[:city_id] )

    if @city.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    # BOO: HARD CODED LOCATION
    @subscriber = Subscriber.new( :location => [@city.location[0], @city.location[1]], :place_json=>"{\"address_components\":[{\"long_name\":\"Vancouver\",\"short_name\":\"Vancouver\",\"types\":[\"locality\",\"political\"]}" )
    @issue = @city.issues.find params[:id]
    if @issue.nil?
      raise ActionController::RoutingError.new('Not Found')
    end

    respond_to do |format|
      format.html {render layout: 'layouts/localread'}
    end

  end

end
