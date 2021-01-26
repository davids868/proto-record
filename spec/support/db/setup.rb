# frozen_string_literal: true

require "active_record"

DB_FILE = "spec/test.db"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: DB_FILE
)

ActiveRecord::Base.connection.data_sources.each do |table|
  ActiveRecord::Base.connection.drop_table(table)
end

ActiveRecord::Schema.define(version: 0) do
  create_table :paths do |t|
    t.string :name
    t.string :description

    t.timestamps
  end

  create_table :features do |t|
    t.string :name
    t.bigint :path_id
    t.json :point
    t.json :points

    t.timestamps
  end
end
