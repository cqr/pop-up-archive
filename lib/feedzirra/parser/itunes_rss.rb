module Feedzirra

  module Parser
    # Parser for dealing with RSS feeds.
    class ItunesRSS
      include SAXMachine
      include FeedUtilities
      element :title
      element :description
      element :link, :as => :url
      elements :item, :as => :entries, :class => ItunesRSSEntry

      attr_accessor :feed_url

      def self.able_to_parse?(xml) #:nodoc:
        (/\<rss|\<rdf/ =~ xml) && !(/feedburner/ =~ xml) &&  (/xmlns:itunes/ =~ xml)
      end
    end

  end

end