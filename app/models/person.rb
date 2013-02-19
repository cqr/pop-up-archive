class Person < ActiveRecord::Base
  attr_accessible :name
  before_save :generate_slug, on: :create
  has_many :contributions

  def self.for_name(string)
    find_by_slug slugify string or create name: string
  end

  def as_json(params={})
    name.as_json
  end

  private

  def generate_slug
    self.slug = self.class.slugify name
  end

  def self.slugify(string)
    string.downcase.gsub(/\W/,'')
  end

end
