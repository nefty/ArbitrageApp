class BaseCurrency < ApplicationRecord
  has_many :currency_pairs
end
