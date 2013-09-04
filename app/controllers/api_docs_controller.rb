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

  protected
    def attributes_and_types(model)
      # Get the AR columns information
      mc = model.columns_hash
      # Keep only the accesible ones
      #mc_accessible = mc.slice(*(mc.keys & model.accessible_attributes.to_a))
      # Return only name and type (ruby type)
      Hash[*mc.map { |k,v| [k,Hash["type",v.type.to_s]] }.flatten]
    end
end
