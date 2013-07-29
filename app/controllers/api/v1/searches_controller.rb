class Api::V1::SearchesController < Api::V1::BaseController
  def show
    query_builder = QueryBuilder.new(params, current_user)
    page = params[:page].to_i

    @search = Item.search do

      if page.present? && page > 1
        from (page - 1) * 25
      end
      size 25

      query_builder.query do |q|
        query &q
      end

      query_builder.facets do |my_facet|
        facet my_facet.name, &my_facet
      end

      query_builder.filters do |my_filter|
        filter my_filter.type, my_filter.value
      end

      highlight transcript: { number_of_fragments: 0 }
    end

    @search.results.each do |result|
      if result.highlight[:transcript].present?
        map = Hash[result.highlight[:transcript].map{|t| [t.gsub(/<\/?em>/, ''), t]}]
      else
        map = {}
      end

      def result.audio_files
        @_audio_files ||= []
      end

      def result.highlighted_transcripts
        @_highlighted_transcripts ||= []
      end

      result.transcripts.each do |t|
        result.audio_files.push AudioFile.find(t.audio_file_id) unless result.audio_files.map(&:id).include? t.audio_file_id
      end

      result.audio_files.each do |af|
        af.transcript_array.each do |tl|
          if map[tl[:text]].present?
            tl[:text] = map[tl[:text]]
            result.highlighted_transcripts.push(tl)
          end
        end
      end
    end

    respond_with @search
  end
end
