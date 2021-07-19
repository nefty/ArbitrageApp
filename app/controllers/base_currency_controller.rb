class BaseCurrencyController < ApplicationController
  def index
    @currencies = BaseCurrency.all
  end
end
