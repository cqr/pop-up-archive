attributes :id, :url, :filename

node :transcript do |af|
  af.transcript_array
end