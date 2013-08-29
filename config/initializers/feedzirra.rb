require 'feedzirra'

Feedzirra::Feed.add_feed_class(Feedzirra::Parser::MediaRSS)
Feedzirra::Feed.add_feed_class(Feedzirra::Parser::MediaRSSFeedBurner)
Feedzirra::Feed.add_feed_class(Feedzirra::Parser::ItunesRSS)
