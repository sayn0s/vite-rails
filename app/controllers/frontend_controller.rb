class FrontendController < ApplicationController
  def index
    render 'frontend/index', layout: 'application'
  end
end
