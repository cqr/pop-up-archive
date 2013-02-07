class HstoreCoder < ActiveRecord::Coders::Hstore
  def initialize(default={})
    @_default = default
    super(default)
  end

  def load(hstore)
    hstore.nil? ? @_default.dup : hstore.from_hstore
  end
end