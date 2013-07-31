module Feedzirra
  
  module Parser

    class MediaRSSRestriction
      include SAXMachine
      include FeedEntryUtilities

      attribute :relationship
      attribute :type, :as => :restriction_type
      value :value

    end

  end

end