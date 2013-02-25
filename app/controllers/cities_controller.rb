class CitiesController< ApplicationController
  def index
    @cities = City.all
  end

  def show
    @city = City.forgiving_find( params[:id] )

    if @city.nil?
      raise ActionController::RoutingError.new('Not Found')
    end

    respond_to do |format|
      format.html
    end
  end

end
