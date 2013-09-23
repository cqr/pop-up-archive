attributes :id, :filename, :transcoded_at
attributes :urls => :url

node :transcript do |af|
  af.transcript_array
end