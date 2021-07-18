class ChangeCurrencyPairs < ActiveRecord::Migration[6.1]
  def change
    rename_column :currency_pairs, :exhange_rate, :exchange_rate
  end
end
