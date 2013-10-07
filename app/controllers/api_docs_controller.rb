class ApiDocsController < AuthedController

  def index
    render "index", layout: false
  end

  def glassfit
    @base = root_url
    render "api_docs/#{params[:version]}/glassfit", formats: :json
  end

  def account
    @base = root_url
    @model = User # Is the model th User???
    @info = attributes_and_types(@model)
    render "api_docs/#{params[:version]}/account", formats: :json
  end

  def devices
    @base = root_url
    render "api_docs/#{params[:version]}/devices", formats: :json
  end

  def transactions
    @base = root_url
    render "api_docs/#{params[:version]}/transactions", formats: :json
  end

  def tracks
    @base = root_url
    render "api_docs/#{params[:version]}/tracks", formats: :json
  end

  def orientations
    @base = root_url
    render "api_docs/#{params[:version]}/orientations", formats: :json
  end

  def positions
    @base = root_url
    render "api_docs/#{params[:version]}/positions", formats: :json
  end

  def friends
    @base = root_url
    render "api_docs/#{params[:version]}/friends", formats: :json
  end

  def data
    @base = root_url
    render "api_docs/#{params[:version]}/data", formats: :json
  end



  protected
    def attributes_and_types(model)
      # Get the AR columns information
      mc = model.columns_hash
      # Keep only the accesible ones
      #mc_accessible = mc.slice(*(mc.keys & model.accessible_attributes.to_a))
      # Return only name and type (ruby type)
      Hash[*mc.map { |k,v| [k,Hash["type",v.type == 'datetime' ? 'dateTime' : v.type.to_s]] }.flatten]
    end
end
