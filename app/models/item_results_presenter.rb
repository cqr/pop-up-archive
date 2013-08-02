class ItemResultsPresenter < BasicObject

  def initialize(results)
    @results = results
  end

  def results
    @_results ||= @results.map {|result| ItemResultPresenter.new(result) }
  end

  def respond_to?(method)
    super || @results.respond_to?(method)
  end

  def method_missing(method, *args)
    if @results.respond_to?(method)
      @results.send method, *args
    else
      super
    end
  end

  class ItemResultPresenter < BasicObject

    def initialize(result)
      @result = result
    end

    def loaded_from_database?
      !!@_result
    end

    def database_object
      @_result ||= ::Item.find(id)
    end

    def audio_files
      @_audio_files ||= transcripts.map(&:audio_file_id).uniq.map {|id| ::AudioFile.find(id) }
    end

    def highlighted_audio_files
      @_highlighted_audio_files ||= generate_highlighted_audio_files
    end

    def entities
      @_entities ||= build_entities
    end

    def respond_to?(method)
      [:audio_files, :highlighted_audio_files, :entities].include?(method) || @result.respond_to?(method) || database_object.respond_to?(method)
    end

    def method_missing(method, *args)
      if loaded_from_database? && database_object.respond_to?(method)
        return database_object.send method, *args
      end

      if @result.respond_to? method
        @result.send method, *args
      elsif database_object.respond_to? method
        database_object.send method, *args
      else
        raise "Unsupported Method"
      end
    end

    private

    def generate_highlighted_audio_files
      if @result.highlight.present? && @result.highlight[:transcript].present?
        lookup = ::Hash[@result.highlight[:transcript].map{|t| [t.gsub(/<\/?em>/, ''), t]}]
      else
        lookup = {}
      end

      [].tap do |results|
        audio_files.each do |audio_file|
          stubbed_audio_file = nil
          audio_file.transcript_array.each do |timed_text|
            if lookup[timed_text['text']].present?
              results.push(stubbed_audio_file = HighlightedAudioFilePresenter.new(audio_file)) unless stubbed_audio_file
              timed_text['text'] = lookup[timed_text['text']]              
              stubbed_audio_file.transcript_array.push timed_text
            end
          end
        end
      end
    end

    def build_entities
      [].tap do |results|
        [:confirmed_entities, :high_unconfirmed_entities, :mid_unconfirmed_entities, :low_unconfirmed_entities].each do |ec|
          results.concat @result.send(ec).map {|e| EntityPresenter.new(e) }
        end
      end
    end
  end

  class HighlightedAudioFilePresenter
    attr_reader :id, :url, :filename, :transcript_array
    def initialize(audio_file)
      @id = audio_file.id
      @url = audio_file.url
      @filename = audio_file.filename
      @transcript_array = []
    end
  end

  class EntityPresenter
    attr_reader :name, :category, :extra
    def initialize(entity)
      @name = entity.entity
      @category = entity.category
    end

    def class
      ::Entity
    end
  end

end