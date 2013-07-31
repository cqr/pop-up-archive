module Feedzirra
  
  module Parser

    class MediaRSSEmbedParam
      include SAXMachine
      include FeedEntryUtilities

      attribute :name
      value :value

    end

  end

end