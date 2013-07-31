module Feedzirra
  
  module Parser

    class MediaRSSHref
      include SAXMachine
      include FeedEntryUtilities

      attribute :type, :as => :link_type
      attribute :lang
      attribute :href

    end

  end

end