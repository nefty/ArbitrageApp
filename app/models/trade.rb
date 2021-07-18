class Trade < ApplicationRecord
  belongs_to :opportunity
  belongs_to :currency_pair
end
