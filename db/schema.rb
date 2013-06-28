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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130111170618) do

  create_table "bing_stats", :force => true do |t|
    t.string   "url"
    t.integer  "http_code"
    t.string   "response_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "craigslist_template_hits", :force => true do |t|
    t.string   "guid"
    t.integer  "property_id"
    t.string   "ip"
    t.datetime "log_stamp"
    t.datetime "post_date"
    t.string   "referrer"
    t.string   "template"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "craigslist_template_hits", ["log_stamp"], :name => "index_craigslist_template_hits_on_log_stamp"

  create_table "google_source_stats", :force => true do |t|
    t.string   "url"
    t.string   "linked_from"
    t.datetime "discovery_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "google_stat_aggregates", :force => true do |t|
    t.integer  "_400_error"
    t.integer  "_403_error"
    t.integer  "_404_not_found"
    t.integer  "_404_like_content"
    t.integer  "_500_error"
    t.integer  "_502_error"
    t.integer  "_503_error"
    t.integer  "_network_unreachable"
    t.integer  "_no_response"
    t.integer  "_redirect_error"
    t.integer  "_redirecting_to_error_page"
    t.integer  "_truncated_response"
    t.integer  "_url_restricted_by_robots_txt"
    t.datetime "date"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "_406_error"
    t.integer  "_connection_reset"
    t.integer  "_401_error"
  end

  create_table "google_stats", :force => true do |t|
    t.string   "url"
    t.string   "detail"
    t.string   "linked_from"
    t.datetime "detected"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ipcaches", :force => true do |t|
    t.string   "ip"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "property_compares", :force => true do |t|
    t.string   "dupe_type"
    t.string   "dupe_url"
    t.string   "overview_url"
    t.integer  "property_id"
    t.integer  "listing"
    t.string   "property_type"
    t.integer  "active"
    t.integer  "alt_property_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phase2_score"
    t.text     "phase2_short_report"
    t.text     "phase2_long_report"
  end

end
