class ImportMapping < ActiveRecord::Base
  belongs_to :csv_import
  attr_accessible :column, :type
  acts_as_list scope: :csv_import_id

  def type=(val)
    self.data_type = val
  end


  def apply(value, model)
    apply_column = column
    transformed_value = transform(value)

    if transformed_value.present?
      while apply_column =~ /\./
        sender, apply_column = apply_column.split('.')
        model = model.send(sender)
      end

      if apply_column =~ /\[\]$/
        apply_column = apply_column.sub(/\[\]$/, '')
        model.send(apply_column).push(transform(value))
      elsif
        if model.respond_to?(:"#{apply_column}=")
          model.send(:"#{apply_column}=", transform(value))
        elsif model.respond_to?(:[]=)
          model[apply_column.intern] = transform(value)
        end
      end
    end
  end

  private

  def transform(value)
    if value.present?
      case data_type
      when "string" then value.to_s
      when "geolocation" then value.to_s
      when "person" then Person.for_name(value)
      when "array" then value.split(',')
      when "short_text" then value.to_s
      when "number" then value.to_i
      when "text" then value.to_s
      when "date" then DateTime.parse(value) rescue nil
      when "*" then value.to_s
      end
    else
      value
    end
  end
end
