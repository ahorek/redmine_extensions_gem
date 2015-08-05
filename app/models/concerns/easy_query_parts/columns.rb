module EasyQueryParts
  class EasyQueryColumn
    include Redmine::I18n

    attr_accessor :name, :no_link, :includes, :joins, :preload, :type

    def initialize(*attrs)
      options = attrs.last.is_a?(Hash) ? attrs.pop : {}
      column = attrs.shift
      if column.is_a?(ActiveRecord::ConnectionAdapters::Column)
        @column = column
        self.name = column.name.to_sym
        @type = column.type
      else
        self.name = column.to_sym
      end
      @type = options[:type]
      @caption_key = options[:caption] || "field_#{name}"
      @title = options[:title]
      @no_link = options[:no_link].nil? ? false : options[:no_link]
      @inline = options.key?(:inline) ? options[:inline] : true
      @full_rows_column = options[:full_rows_column].nil? ? false : options[:full_rows_column]
      @includes = options[:includes]
      @joins = Array(options[:joins])
      @preload = options[:preload]
    end

    def caption(with_suffixes=false)
      @title || l(@caption_key)
    end

    def inline?
      @inline
    end

    def visible?
      true
    end

    def numeric?
      [:integer].include?(type)
    end

    def full_rows_column?
      self.inline? && @full_rows_column
    end

    def value(entity, options={})
      entity.nested_send(self.name)
    end

    def value_object(entity, options={})
      self.value(entity, options)
    end

    def css_classes
      @css_classes ||= [self.name.to_s.underscore, (self.numeric? ? ((User.current.pref.number_alignment == '0') ? 'right-alignment' : 'left-alignment') : '')].reject(&:blank?).join(' ')
    end
  end

  module Columns

    def rejected_columns
      %w(id)
    end


    def load_entity_columns
      result = []
      entity.columns.each do |column|
        result << EasyQueryColumn.new(column) unless rejected_columns.include?(column.name)
      end
    end

    def columns_from_associations
      []
    end

    def available_columns
      return @available_columns if @available_columns
      @available_columns = load_entity_columns
    end

  end
end