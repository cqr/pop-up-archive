# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'fastercsv'
Dir[File.expand_path('../seed/*csv', __FILE__)].each do |file|
  FasterCSV.foreach file do |row|

  end
end