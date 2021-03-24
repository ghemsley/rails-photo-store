class SearchesController < ApplicationController
  def search
    if !(params[:query].nil? || params[:query] == '')
      @query = search_params(:query)
      @products = Product.name_or_description_contains(@query)
    else
      @query = ''
      @products = []
    end
  end

  def search_params(*args)
    params.require(*args)
  end
end
