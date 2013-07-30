object transcript

attributes :language
child timed_texts: 'parts' do
  node(:start) {|tt| format_time(tt.start_time) }
  node(:end)   {|tt| format_time(tt.end_time) }
  attribute :text
end