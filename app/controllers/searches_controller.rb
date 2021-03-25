class SearchesController < ApplicationController
  def search
    @admin = get_admin_if_signed_in
    if !(params[:query].nil? || params[:query] == '')
      @query = search_params(:query)
      @products = Product.metadata_contains(@query)
    else
      @query = ''
      @products = []
    end
  end

  private

  def search_params(*args)
    params.require(*args)
  end
end
