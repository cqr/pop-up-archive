require 'feedzirra'

Feedzirra::Feed.add_feed_class(Feedzirra::Parser::MediaRSSFeedBurner)
Feedzirra::Feed.add_feed_class(Feedzirra::Parser::MediaRSS)

Feedzirra::Feed.add_common_feed_entry_element("link", :value => :href, :as => :enclosure_url, :with => {:rel => "enclosure"})
Feedzirra::Feed.add_common_feed_entry_element("link", :value => :length, :as => :enclosure_length, :with => {:rel => "enclosure"})
Feedzirra::Feed.add_common_feed_entry_element("link", :value => :type, :as => :enclosure_type, :with => {:rel => "enclosure"})

Feedzirra::Feed.add_common_feed_entry_element("enclosure", :value => :length, :as => :enclosure_length)
Feedzirra::Feed.add_common_feed_entry_element("enclosure", :value => :type, :as => :enclosure_type)
Feedzirra::Feed.add_common_feed_entry_element("enclosure", :value => :url, :as => :enclosure_url)
