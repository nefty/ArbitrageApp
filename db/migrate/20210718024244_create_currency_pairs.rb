class CreateCurrencyPairs < ActiveRecord::Migration[6.1]
  def change
    create_table :currency_pairs do |t|
      t.bigint :base_currency
      t.bigint :quote_currency
      t.float :exchange_rate

      t.belongs_to :exchange

      t.timestamps
    end
  end
end
