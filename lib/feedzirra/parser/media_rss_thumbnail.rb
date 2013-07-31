module Feedzirra
  
  module Parser

    class MediaRSSThumbnail
      include SAXMachine
      include FeedEntryUtilities

      attribute :url
      attribute :width
      attribute :height
      attribute :time

    end

  end

end