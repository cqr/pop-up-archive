module Feedzirra
  
  module Parser

    class MediaRSSScheme
      include SAXMachine
      include FeedEntryUtilities

      attribute :scheme
      attribute :role
      value :value

    end

  end

end