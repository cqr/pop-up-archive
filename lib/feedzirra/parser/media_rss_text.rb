module Feedzirra
  
  module Parser

    class MediaRSSText
      include SAXMachine
      include FeedEntryUtilities

      attribute :type, :as => :content_type
      value :value

    end

  end

end