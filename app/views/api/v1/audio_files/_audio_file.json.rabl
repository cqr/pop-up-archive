attributes :id, :url, :filename

node :transcript do |af|
  JSON.parse(af.transcript) unless af.transcript.blank?
end