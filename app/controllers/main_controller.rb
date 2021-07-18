class MainController < ApplicationController
  def index
    @opportunities = Opportunity.all
  end
end
