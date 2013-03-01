class QueryBuilder::Filter
  attr_accessor :type, :value

  def initialize(name, options)
    @name         = name
    @type, @value = decode_options(options)
  end

  def to_proc
    lambda { |search| search.send(type.intern, value)}
  end

  def to_h
    {type => value}
  end

  private

  def decode_options(options)
    if options.kind_of? String
      [:term, {@name => options}]
    else
      [(options.delete(:type) || :term), {@name => options[:value]}]
    end
  end
end