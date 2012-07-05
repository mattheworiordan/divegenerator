require './lib/generators/generators.rb'

module Generators
  dbconfig = YAML.load(File.read('config/database.yml'))
  ActiveRecord::Base.establish_connection dbconfig[:development.to_s]

  ActiveRecord::Migration::drop_table(:disciplines) if Discipline.table_exists?
  ActiveRecord::Migration::drop_table(:moves) if Move.table_exists?

  ActiveRecord::Schema.define do
      create_table :disciplines do |table|
          table.column :title, :string
          table.column :min_points_per_round, :integer
      end

      create_table :moves do |table|
          table.column :discipline_id, :integer
          table.column :title, :string
          table.column :shortname, :string
          table.column :points, :integer
          table.column :move_type, :integer
      end
  end

  (discipline = Discipline.new(:title => "Freeflying", :min_points_per_round => 5)).save
  ('1'..'10').each { |v| Move.new(:discipline_id => discipline.id, :title => "Unknown", :shortname => v.to_s, :points => 1, :move_type => DIVE_RANDOM).save }

  (discipline = Discipline.new(:title => "Freestyle", :min_points_per_round => 5)).save
  ('1'..'10').each { |v| Move.new(:discipline_id => discipline.id, :title => "Unknown", :shortname => v.to_s, :points => 1, :move_type => DIVE_RANDOM).save }

  (discipline = Discipline.new(:title => "VFS - Vertical Formation Skydiving", :min_points_per_round => 4)).save
  ('1'..'14').each { |v| Move.new(:discipline_id => discipline.id, :title => "Unknown", :shortname => v.to_s, :points => 2, :move_type => DIVE_BLOCK).save }
  ('A'..'L').each { |v| Move.new(:discipline_id => discipline.id, :title => "Unknown", :shortname => v.to_s, :points => 1, :move_type => DIVE_RANDOM).save }

  (discipline = Discipline.new(:title => "FS - Formation Skydiving", :min_points_per_round => 4)).save
  ('A'..'Q').each { |v| Move.new(:discipline_id => discipline.id, :title => "Unknown", :shortname => v.to_s, :points => 2, :move_type => DIVE_BLOCK).save }
  ('1'..'22').each { |v| Move.new(:discipline_id => discipline.id, :title => "Unknown", :shortname => v.to_s, :points => 1, :move_type => DIVE_RANDOM).save }
end