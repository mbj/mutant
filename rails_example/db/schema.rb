# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2) do
  create_table :users, force: true do |t|
    t.integer  :age, null: false
    t.datetime :deleted_at
    t.string   :status
    t.string   :region
    t.datetime :created_at
  end
end
