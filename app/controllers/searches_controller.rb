class SearchesController < ApplicationController
  def search
    @admin = get_admin_if_signed_in
    @query = params[:query]
    @products = if params[:filters].present?
                  Product.includes(dimensions: :price_modifier).filter_metadata(@query, params[:filters])
                else
                  Product.includes(dimensions: :price_modifier).metadata_contains(@query)
                end
  end

  private

  def search_params(*args)
    params.require(*args)
  end
end
