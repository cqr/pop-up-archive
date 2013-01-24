# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if File.exists?(File.expand_path('../seed/one.csv', __FILE__))
  require 'csv'

  COLUMNS = [nil, :identifier, nil, nil, nil, nil, :tags, nil, nil, nil, nil, nil, :title, :description, nil, :date_created, :rights, :digital_location, :episode_title, :series_title, :music_sound_used, :notes, :physical_format, :physical_location, :duration, nil, nil, :date_broadcast, nil]
  HEADERS = "recordType|itemId|itemType|collection|public|featured|tags|file|fileId|fileSource|fileOrder|PBCore:Identifier|PBCore:Title|PBCore:Description|PBCore:Creator|PBCore:Date Created|PBCore:Rights|PBCore:Digital Location|PBCore:Episode Title|PBCore:Series Title|PBCore:Music/Sound Used|PBCore:Notes|PBCore:Physical Format|PBCore:Physical Location|PBCore:Duration|PBCore:Interviewer|PBCore:Interviewee|PBCore:Date Broadcast|PBCore:Host".split("|").map{|x|x.gsub(/:+/,'_')}.map(&:underscore).map(&:titleize) 
  CSV.foreach(File.expand_path('../seed/one.csv', __FILE__), col_sep: '|', headers: true) do |row|
    item = Item.new(extra:{})
    COLUMNS.each_with_index do |key, index|
      if key.nil?
        item.extra[HEADERS[index].underscore] = row[index]
      else
        item.send(:"#{key}=", row[index])
      end
    end
    puts item.inspect
    item.save
  end
end