# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160512052639) do

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", primary_key: "employee_id", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "department_id"
    t.boolean  "admin"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "employees", ["department_id"], name: "index_employees_on_department_id"
  add_index "employees", ["reset_password_token"], name: "index_employees_on_reset_password_token", unique: true

  create_table "timelogs", force: :cascade do |t|
    t.integer  "employee_id"
    t.date     "log_date"
    t.integer  "arrive_sec"
    t.integer  "leave_sec"
    t.integer  "claim_arrive_sec"
    t.integer  "claim_leave_sec"
    t.string   "claim_status"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "timelogs", ["employee_id"], name: "index_timelogs_on_employee_id"

  create_table "timesheets", force: :cascade do |t|
    t.integer  "employee_id"
    t.date     "period_start_date"
    t.date     "period_end_date"
    t.integer  "logged_hrs"
    t.integer  "logged_min"
    t.date     "pay_date"
    t.boolean  "approved"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "timesheets", ["employee_id"], name: "index_timesheets_on_employee_id"

end
