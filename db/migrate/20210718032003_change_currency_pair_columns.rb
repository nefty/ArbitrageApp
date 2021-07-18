class ChangeCurrencyPairColumns < ActiveRecord::Migration[6.1]
  def change
    change_column :currency_pairs, :base_currency, :bigint
    change_column :currency_pairs, :quote_currency, :bigint
  end
end
