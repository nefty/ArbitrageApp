# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_18_174505) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "base_currencies", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_base_currencies_on_code"
  end

  create_table "currency_pairs", force: :cascade do |t|
    t.bigint "exchange_id"
    t.bigint "base_currency_id"
    t.bigint "quote_currency_id"
    t.float "exchange_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["base_currency_id"], name: "index_currency_pairs_on_base_currency_id"
    t.index ["exchange_id"], name: "index_currency_pairs_on_exchange_id"
    t.index ["quote_currency_id"], name: "index_currency_pairs_on_quote_currency_id"
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "opportunities", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "quote_currencies", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_quote_currencies_on_code"
  end

  create_table "trades", force: :cascade do |t|
    t.bigint "opportunity_id"
    t.bigint "currency_pair_id"
    t.integer "order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["currency_pair_id"], name: "index_trades_on_currency_pair_id"
    t.index ["opportunity_id"], name: "index_trades_on_opportunity_id"
  end

end
