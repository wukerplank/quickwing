class RootController < ApplicationController

  # GET /search
  def search

    @location = params[:q]

    respond_to do |format|
      format.html { render 'root/index' } # index.html.erb
    end
  end

end
