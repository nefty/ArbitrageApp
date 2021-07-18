class IndexCurrencyCode < ActiveRecord::Migration[6.1]
  def change
    add_index :base_currencies, :code
    add_index :quote_currencies, :code
  end
end
