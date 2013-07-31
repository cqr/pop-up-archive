module Feedzirra
  
  module Parser

    class MediaRSSEmbed
      include SAXMachine
      include FeedEntryUtilities

      attribute :url
      attribute :width
      attribute :height

      elements :"media:param", :as => :params, :class => MediaRSSEmbedParam

    end

  end

end