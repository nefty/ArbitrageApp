class CreateAllTables < ActiveRecord::Migration[6.1]
  def change
    create_table :base_currencies do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    create_table :quote_currencies do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    create_table :currency_pairs do |t|
      t.belongs_to :exchange
      t.belongs_to :base_currency
      t.belongs_to :quote_currency

      t.float :exhange_rate

      t.timestamps
    end

    create_table :exchanges do |t|
      t.string :name

      t.timestamps
    end

    create_table :opportunities do |t|
      t.timestamps
    end

    create_table :trades do |t|
      t.belongs_to :opportunity
      t.belongs_to :currency_pair

      t.integer :order

      t.timestamps
    end
  end
end
