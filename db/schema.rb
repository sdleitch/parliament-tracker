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

ActiveRecord::Schema.define(version: 20160429191703) do

  create_table "bills", force: :cascade do |t|
    t.date     "date_introduced"
    t.string   "prefix"
    t.integer  "number"
    t.string   "title_long"
    t.string   "title_short"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "bill_type"
    t.integer  "parliament_number"
    t.integer  "member_id"
  end

  add_index "bills", ["member_id"], name: "index_bills_on_member_id"

  create_table "electoral_districts", force: :cascade do |t|
    t.string   "name"
    t.text     "geo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "province"
  end

  create_table "members", force: :cascade do |t|
    t.integer  "party_id"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "email"
    t.string   "website"
    t.integer  "electoral_district_id"
    t.string   "honorific"
    t.string   "headshot_file_name"
    t.string   "headshot_content_type"
    t.integer  "headshot_file_size"
    t.datetime "headshot_updated_at"
  end

  add_index "members", ["electoral_district_id"], name: "index_members_on_electoral_district_id"
  add_index "members", ["party_id"], name: "index_members_on_party_id"

  create_table "members_parliments", id: false, force: :cascade do |t|
    t.integer "parliment_id", null: false
    t.integer "member_id",    null: false
  end

  add_index "members_parliments", ["member_id", "parliment_id"], name: "index_members_parliments_on_member_id_and_parliment_id"
  add_index "members_parliments", ["parliment_id", "member_id"], name: "index_members_parliments_on_parliment_id_and_member_id"

  create_table "parliments", force: :cascade do |t|
    t.integer  "number"
    t.date     "startdate"
    t.date     "enddate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parliments_parties", id: false, force: :cascade do |t|
    t.integer "parliment_id", null: false
    t.integer "party_id",     null: false
  end

  add_index "parliments_parties", ["parliment_id", "party_id"], name: "index_parliments_parties_on_parliment_id_and_party_id"
  add_index "parliments_parties", ["party_id", "parliment_id"], name: "index_parliments_parties_on_party_id_and_parliment_id"

  create_table "parties", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vote_tallies", force: :cascade do |t|
    t.boolean  "agreed_to"
    t.integer  "vote_number"
    t.date     "date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "para"
    t.integer  "bill_id"
    t.integer  "member_id"
  end

  add_index "vote_tallies", ["bill_id"], name: "index_vote_tallies_on_bill_id"
  add_index "vote_tallies", ["member_id"], name: "index_vote_tallies_on_member_id"

  create_table "votes", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "vote_tally_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "vote_decision"
  end

  add_index "votes", ["member_id"], name: "index_votes_on_member_id"
  add_index "votes", ["vote_tally_id"], name: "index_votes_on_vote_tally_id"

end
