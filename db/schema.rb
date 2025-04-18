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

ActiveRecord::Schema[8.0].define(version: 2025_04_18_195004) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "expense_shares", force: :cascade do |t|
    t.integer "expense_id", null: false
    t.integer "user_id", null: false
    t.decimal "amount_owed", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_id", "user_id"], name: "index_expense_shares_on_expense_id_and_user_id", unique: true
    t.index ["expense_id"], name: "index_expense_shares_on_expense_id"
    t.index ["user_id"], name: "index_expense_shares_on_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "paid_by_id", null: false
    t.integer "group_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_expenses_on_group_id"
    t.index ["paid_by_id"], name: "index_expenses_on_paid_by_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "friend_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "group_messages", force: :cascade do |t|
    t.text "content", null: false
    t.boolean "system", default: false
    t.integer "group_id", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_messages_on_group_id"
    t.index ["user_id"], name: "index_group_messages_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.integer "created_by", null: false
    t.string "invite_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_token"], name: "index_groups_on_invite_token", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "payer_id", null: false
    t.integer "receiver_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payer_id"], name: "index_payments_on_payer_id"
    t.index ["receiver_id"], name: "index_payments_on_receiver_id"
  end

  create_table "settlements", force: :cascade do |t|
    t.integer "payer_id", null: false
    t.integer "payee_id", null: false
    t.integer "group_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_settlements_on_group_id"
    t.index ["payee_id"], name: "index_settlements_on_payee_id"
    t.index ["payer_id"], name: "index_settlements_on_payer_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.string "concurrency_key", null: false
    t.index ["concurrency_key"], name: "index_solid_queue_blocked_executions_on_concurrency_key"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.datetime "run_at", null: false
    t.datetime "locked_at"
    t.string "locked_by"
    t.integer "attempts", default: 0, null: false
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["run_at"], name: "index_solid_queue_jobs_on_run_at"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.string "name"
    t.datetime "last_heartbeat_at"
    t.integer "supervisor_id"
    t.integer "pid"
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.index ["queue_name", "priority", "scheduled_at"], name: "idx_on_queue_name_priority_scheduled_at_d908db28b2"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.text "arguments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_key"], name: "index_solid_queue_recurring_executions_on_task_key", unique: true
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.index ["queue_name", "priority", "scheduled_at"], name: "idx_on_queue_name_priority_scheduled_at_737a65c8e1"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "transaction_histories", force: :cascade do |t|
    t.integer "payer_id", null: false
    t.integer "receiver_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "settlement_id"
    t.index ["payer_id"], name: "index_transaction_histories_on_payer_id"
    t.index ["receiver_id"], name: "index_transaction_histories_on_receiver_id"
    t.index ["settlement_id"], name: "index_transaction_histories_on_settlement_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "expense_shares", "expenses"
  add_foreign_key "expense_shares", "users"
  add_foreign_key "expenses", "groups"
  add_foreign_key "expenses", "users", column: "paid_by_id"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "group_messages", "groups"
  add_foreign_key "group_messages", "users"
  add_foreign_key "groups", "users", column: "created_by"
  add_foreign_key "payments", "users", column: "payer_id"
  add_foreign_key "payments", "users", column: "receiver_id"
  add_foreign_key "settlements", "groups"
  add_foreign_key "settlements", "users", column: "payee_id"
  add_foreign_key "settlements", "users", column: "payer_id"
  add_foreign_key "transaction_histories", "settlements"
  add_foreign_key "transaction_histories", "users", column: "payer_id"
  add_foreign_key "transaction_histories", "users", column: "receiver_id"
end
