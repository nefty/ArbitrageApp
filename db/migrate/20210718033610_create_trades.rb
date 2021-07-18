class CreateTrades < ActiveRecord::Migration[6.1]
  def change
    create_table :trades do |t|
      t.belongs_to :opportunity
      t.belongs_to :currency_pair

      t.integer :order

      t.timestamps
    end
  end
end
