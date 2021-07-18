class Exchange < ApplicationRecord
  has_many :currencies
  has_many :currency_pairs
end
