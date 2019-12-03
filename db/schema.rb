# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_03_043207) do

  create_table "admin_permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.bigint "admin_permission_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "password_is_reset"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_permission_id"], name: "index_admin_users_on_admin_permission_id"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "customers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "queue"
    t.string "name"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loc_districts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loc_khoroos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "loc_district_id"
    t.string "name"
    t.integer "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loc_district_id"], name: "index_loc_khoroos_on_loc_district_id"
  end

  create_table "location_travels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "location_from_id"
    t.bigint "location_to_id"
    t.integer "distance"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_from_id"], name: "index_location_travels_on_location_from_id"
    t.index ["location_to_id"], name: "index_location_travels_on_location_to_id"
  end

  create_table "locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "operator_id"
    t.bigint "user_id"
    t.bigint "loc_khoroo_id"
    t.text "name"
    t.text "name_la"
    t.decimal "latitude", precision: 15, scale: 10, default: "0.0"
    t.decimal "longitude", precision: 15, scale: 10, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loc_khoroo_id"], name: "index_locations_on_loc_khoroo_id"
    t.index ["operator_id"], name: "index_locations_on_operator_id"
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "operators", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "surname"
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "phone"
    t.integer "gender"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "password_is_reset"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_operators_on_email", unique: true
    t.index ["reset_password_token"], name: "index_operators_on_reset_password_token", unique: true
  end

  create_table "product_balances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "feature_item_id"
    t.bigint "income_item_id"
    t.bigint "sale_item_id"
    t.bigint "user_id"
    t.bigint "operator_id"
    t.integer "quantity"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_item_id"], name: "index_product_balances_on_feature_item_id"
    t.index ["income_item_id"], name: "index_product_balances_on_income_item_id"
    t.index ["operator_id"], name: "index_product_balances_on_operator_id"
    t.index ["product_id"], name: "index_product_balances_on_product_id"
    t.index ["sale_item_id"], name: "index_product_balances_on_sale_item_id"
    t.index ["user_id"], name: "index_product_balances_on_user_id"
  end

  create_table "product_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "parent_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "sync_at"
    t.index ["parent_id"], name: "index_product_categories_on_parent_id"
  end

  create_table "product_feature_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "feature_rel_id"
    t.bigint "feature1_id"
    t.bigint "option1_id"
    t.bigint "feature2_id"
    t.bigint "option2_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature1_id"], name: "index_product_feature_items_on_feature1_id"
    t.index ["feature2_id"], name: "index_product_feature_items_on_feature2_id"
    t.index ["feature_rel_id"], name: "index_product_feature_items_on_feature_rel_id"
    t.index ["option1_id"], name: "index_product_feature_items_on_option1_id"
    t.index ["option2_id"], name: "index_product_feature_items_on_option2_id"
    t.index ["product_id"], name: "index_product_feature_items_on_product_id"
  end

  create_table "product_feature_option_rels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "feature_rel_id"
    t.bigint "feature_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_option_id"], name: "index_product_feature_option_rels_on_feature_option_id"
    t.index ["feature_rel_id"], name: "index_product_feature_option_rels_on_feature_rel_id"
  end

  create_table "product_feature_options", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "queue"
    t.string "name"
    t.bigint "product_feature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "sync_at"
    t.index ["product_feature_id"], name: "index_product_feature_options_on_product_feature_id"
  end

  create_table "product_feature_rels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_id"
    t.float "sale_price"
    t.float "discount_price", limit: 53
    t.string "barcode", limit: 53
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["product_id"], name: "index_product_feature_rels_on_product_id"
  end

  create_table "product_features", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "queue"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "sync_at"
  end

  create_table "product_income_balances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "supply_order_item_id"
    t.bigint "income_item_id"
    t.bigint "user_supply_id"
    t.bigint "user_income_id"
    t.integer "quantity"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["income_item_id"], name: "index_product_income_balances_on_income_item_id"
    t.index ["product_id"], name: "index_product_income_balances_on_product_id"
    t.index ["supply_order_item_id"], name: "index_product_income_balances_on_supply_order_item_id"
    t.index ["user_income_id"], name: "index_product_income_balances_on_user_income_id"
    t.index ["user_supply_id"], name: "index_product_income_balances_on_user_supply_id"
  end

  create_table "product_income_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_income_id"
    t.bigint "supply_order_item_id"
    t.bigint "product_id"
    t.bigint "product_supplier_id"
    t.bigint "feature_rel_id"
    t.bigint "feature_item_id"
    t.integer "quantity"
    t.float "price", limit: 53
    t.float "sum_price", limit: 53
    t.float "sum_tug", limit: 53
    t.float "shuudan"
    t.integer "urgent_type"
    t.datetime "date"
    t.string "note", limit: 1000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_item_id"], name: "index_product_income_items_on_feature_item_id"
    t.index ["feature_rel_id"], name: "index_product_income_items_on_feature_rel_id"
    t.index ["product_id"], name: "index_product_income_items_on_product_id"
    t.index ["product_income_id"], name: "index_product_income_items_on_product_income_id"
    t.index ["product_supplier_id"], name: "index_product_income_items_on_product_supplier_id"
    t.index ["supply_order_item_id"], name: "index_product_income_items_on_supply_order_item_id"
  end

  create_table "product_income_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "income_item_id"
    t.bigint "location_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["income_item_id"], name: "index_product_income_locations_on_income_item_id"
    t.index ["location_id"], name: "index_product_income_locations_on_location_id"
  end

  create_table "product_incomes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code"
    t.datetime "income_date"
    t.string "note"
    t.float "sum_price", limit: 53
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_product_incomes_on_user_id"
  end

  create_table "product_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "parent_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_product_locations_on_parent_id"
  end

  create_table "product_sale_calls", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "phone"
    t.bigint "product_id"
    t.integer "quantity"
    t.bigint "operator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_product_sale_calls_on_operator_id"
    t.index ["product_id"], name: "index_product_sale_calls_on_product_id"
  end

  create_table "product_sale_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_sale_id"
    t.bigint "product_id"
    t.bigint "feature_rel_id"
    t.bigint "feature_item_id"
    t.integer "quantity"
    t.float "price"
    t.float "sum_price", limit: 53
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "to_see", default: false
    t.index ["feature_item_id"], name: "index_product_sale_items_on_feature_item_id"
    t.index ["feature_rel_id"], name: "index_product_sale_items_on_feature_rel_id"
    t.index ["product_id"], name: "index_product_sale_items_on_product_id"
    t.index ["product_sale_id"], name: "index_product_sale_items_on_product_sale_id"
  end

  create_table "product_sale_status_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_sale_id"
    t.bigint "operator_id"
    t.bigint "status_id"
    t.integer "log_type"
    t.string "note"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_product_sale_status_logs_on_operator_id"
    t.index ["product_sale_id"], name: "index_product_sale_status_logs_on_product_sale_id"
    t.index ["status_id"], name: "index_product_sale_status_logs_on_status_id"
  end

  create_table "product_sale_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "parent_id"
    t.string "name"
    t.string "alias"
    t.string "user_type"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "queue"
    t.index ["parent_id"], name: "index_product_sale_statuses_on_parent_id"
  end

  create_table "product_sales", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code"
    t.datetime "delivery_start"
    t.datetime "delivery_end"
    t.integer "phone"
    t.bigint "location_id"
    t.string "building_code"
    t.string "loc_note"
    t.datetime "delivery_date"
    t.integer "money"
    t.float "bonus"
    t.float "sum_price", limit: 53
    t.bigint "main_status_id"
    t.bigint "status_id"
    t.string "status_note"
    t.bigint "created_operator_id"
    t.bigint "approved_operator_id"
    t.datetime "approved_date"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_operator_id"], name: "index_product_sales_on_approved_operator_id"
    t.index ["created_operator_id"], name: "index_product_sales_on_created_operator_id"
    t.index ["location_id"], name: "index_product_sales_on_location_id"
    t.index ["main_status_id"], name: "index_product_sales_on_main_status_id"
    t.index ["status_id"], name: "index_product_sales_on_status_id"
  end

  create_table "product_suppliers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_supply_order_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "product_supply_order_id"
    t.bigint "supply_order_id"
    t.bigint "product_id"
    t.float "quantity"
    t.float "price", limit: 53
    t.string "link", limit: 500
    t.float "shuudan"
    t.string "note", limit: 1000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "sum_price", limit: 53
    t.float "sum_tug", limit: 53
    t.index ["product_id"], name: "index_product_supply_order_items_on_product_id"
    t.index ["product_supply_order_id"], name: "index_product_supply_order_items_on_product_supply_order_id"
    t.index ["supply_order_id"], name: "index_product_supply_order_items_on_supply_order_id"
  end

  create_table "product_supply_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code"
    t.datetime "ordered_date"
    t.bigint "supplier_id"
    t.integer "payment"
    t.integer "exchange"
    t.float "exchange_value"
    t.float "sum_price", limit: 53
    t.datetime "closed_date"
    t.integer "is_closed", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_product_supply_orders_on_supplier_id"
    t.index ["user_id"], name: "index_product_supply_orders_on_user_id"
  end

  create_table "products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "category_id"
    t.string "name"
    t.string "code"
    t.string "main_code"
    t.string "barcode"
    t.string "detail"
    t.integer "measure"
    t.integer "ptype"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "sync_at"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["customer_id"], name: "index_products_on_customer_id"
  end

  create_table "salesmen", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "surname"
    t.string "name"
    t.integer "gender", default: 0
    t.string "register"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "pin_code"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.text "tokens"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_salesmen_on_email", unique: true
    t.index ["reset_password_token"], name: "index_salesmen_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_salesmen_on_uid_and_provider", unique: true
  end

  create_table "sys_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_sys_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_sys_users_on_uid_and_provider", unique: true
  end

  create_table "travel_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "max_travel"
    t.integer "waiting_time"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_travel_configs_on_user_id"
  end

  create_table "user_permission_rels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "user_permission_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_permission_rels_on_user_id"
    t.index ["user_permission_id"], name: "index_user_permission_rels_on_user_permission_id"
  end

  create_table "user_permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "queue"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_positions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "surname"
    t.string "name"
    t.string "email", default: "", null: false
    t.string "phone"
    t.integer "gender"
    t.bigint "user_position_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "password_is_reset"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_position_id"], name: "index_users_on_user_position_id"
  end

  add_foreign_key "admin_users", "admin_permissions"
  add_foreign_key "loc_khoroos", "loc_districts"
  add_foreign_key "location_travels", "locations", column: "location_from_id"
  add_foreign_key "location_travels", "locations", column: "location_to_id"
  add_foreign_key "locations", "loc_khoroos"
  add_foreign_key "locations", "operators"
  add_foreign_key "locations", "users"
  add_foreign_key "product_balances", "operators"
  add_foreign_key "product_balances", "product_feature_items", column: "feature_item_id"
  add_foreign_key "product_balances", "product_income_items", column: "income_item_id"
  add_foreign_key "product_balances", "product_sale_items", column: "sale_item_id"
  add_foreign_key "product_balances", "products"
  add_foreign_key "product_balances", "users"
  add_foreign_key "product_categories", "product_categories", column: "parent_id"
  add_foreign_key "product_feature_items", "product_feature_options", column: "option1_id"
  add_foreign_key "product_feature_items", "product_feature_options", column: "option2_id"
  add_foreign_key "product_feature_items", "product_feature_rels", column: "feature_rel_id"
  add_foreign_key "product_feature_items", "product_features", column: "feature1_id"
  add_foreign_key "product_feature_items", "product_features", column: "feature2_id"
  add_foreign_key "product_feature_items", "products"
  add_foreign_key "product_feature_option_rels", "product_feature_options", column: "feature_option_id"
  add_foreign_key "product_feature_option_rels", "product_feature_rels", column: "feature_rel_id"
  add_foreign_key "product_feature_options", "product_features"
  add_foreign_key "product_feature_rels", "products"
  add_foreign_key "product_income_balances", "product_income_items", column: "income_item_id"
  add_foreign_key "product_income_balances", "product_supply_order_items", column: "supply_order_item_id"
  add_foreign_key "product_income_balances", "products"
  add_foreign_key "product_income_balances", "users", column: "user_income_id"
  add_foreign_key "product_income_balances", "users", column: "user_supply_id"
  add_foreign_key "product_income_items", "product_feature_items", column: "feature_item_id"
  add_foreign_key "product_income_items", "product_feature_rels", column: "feature_rel_id"
  add_foreign_key "product_income_items", "product_incomes"
  add_foreign_key "product_income_items", "product_suppliers"
  add_foreign_key "product_income_items", "product_supply_order_items", column: "supply_order_item_id"
  add_foreign_key "product_income_items", "products"
  add_foreign_key "product_income_locations", "product_income_items", column: "income_item_id"
  add_foreign_key "product_income_locations", "product_locations", column: "location_id"
  add_foreign_key "product_incomes", "users"
  add_foreign_key "product_locations", "product_locations", column: "parent_id"
  add_foreign_key "product_sale_calls", "operators"
  add_foreign_key "product_sale_calls", "products"
  add_foreign_key "product_sale_items", "product_feature_items", column: "feature_item_id"
  add_foreign_key "product_sale_items", "product_feature_rels", column: "feature_rel_id"
  add_foreign_key "product_sale_items", "product_sales"
  add_foreign_key "product_sale_items", "products"
  add_foreign_key "product_sale_status_logs", "operators"
  add_foreign_key "product_sale_status_logs", "product_sale_statuses", column: "status_id"
  add_foreign_key "product_sale_status_logs", "product_sales"
  add_foreign_key "product_sale_statuses", "product_sale_statuses", column: "parent_id"
  add_foreign_key "product_sales", "locations"
  add_foreign_key "product_sales", "operators", column: "approved_operator_id"
  add_foreign_key "product_sales", "operators", column: "created_operator_id"
  add_foreign_key "product_sales", "product_sale_statuses", column: "main_status_id"
  add_foreign_key "product_sales", "product_sale_statuses", column: "status_id"
  add_foreign_key "product_supply_order_items", "product_supply_orders"
  add_foreign_key "product_supply_order_items", "product_supply_orders", column: "supply_order_id"
  add_foreign_key "product_supply_order_items", "products"
  add_foreign_key "product_supply_orders", "product_suppliers", column: "supplier_id"
  add_foreign_key "product_supply_orders", "users"
  add_foreign_key "products", "customers"
  add_foreign_key "products", "product_categories", column: "category_id"
  add_foreign_key "travel_configs", "users"
  add_foreign_key "user_permission_rels", "user_permissions"
  add_foreign_key "user_permission_rels", "users"
  add_foreign_key "users", "user_positions"
end
