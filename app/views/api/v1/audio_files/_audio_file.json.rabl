attributes :id, :url, :filename, :transcoded_at

node :transcript do |af|
  af.transcript_array
end