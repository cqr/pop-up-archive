module Feedzirra
  
  module Parser

    class MediaRSSContent
      include SAXMachine
      include FeedEntryUtilities

      attribute :url
      attribute :fileSize, :as => :file_size
      attribute :type, :as => :content_type
      attribute :medium
      attribute :isDefault, :as => :is_default
      attribute :expression
      attribute :bitrate
      attribute :framerate
      attribute :samplingrate
      attribute :channels
      attribute :duration
      attribute :height
      attribute :width
      attribute :lang

    end

  end

end