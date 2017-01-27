module ValidationErrorSerializer
  def self.serialize(object)
    return if object.valid?

    errors = object.errors.to_hash
    extract_errors object, errors
  end

  private
  def self.extract_errors(object, errors, parent = nil)
    # This return value makes this method incompatible with relations that
    # are collections which contain more collections (e.g. user.matches.messages),
    # but that's okay because we don't need support for those cases here
    return if object.class.to_s.match /Mongoid/

    object.relations.each do |relation_name, relation_type|
      next unless relation_type.macro.match /(has|embeds)_/

      related_object = object.send relation_name
      next if related_object.nil?

      related_errors = if relation_type.macro.match /_many/
        related_object.map{|o| { o.id.to_s => o.errors.to_hash } unless o.errors.empty?}.compact
      else
        related_object.errors.to_hash
      end

      error_base = parent.nil? ? errors : errors[parent]
      error_base[relation_name.to_sym] = related_errors if related_errors.any?

      if more_relations_exist_for? related_object
        extract_errors related_object, errors, relation_name.to_sym
      end
    end

    errors
  end

  def self.more_relations_exist_for?(object)
    object.relations.map{|name, type| type.macro}.select{|r| r.match /(has|embeds)_/}.any?
  end
end
