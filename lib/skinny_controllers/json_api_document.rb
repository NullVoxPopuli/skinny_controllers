module SkinnyControllers
  # currently copied from NullVoxPopuli/json-api-document
  # Not sure if this should be its own gem or not
  class JsonApiDocument
    attr_accessor :data, :id, :attributes

    # @param [Hash] json the json api document
    # @param [Symbol] key_formatter converts the attribute keys
    def initialize(json, key_formatter: nil)
      json = JSON.parse(json) if json.is_a?(String)

      self.data = json['data']
      self.id = json['id'] || data['id']
      self.attributes = format_keys(data['attributes'], key_formatter)
    end

    private

    # TODO: how to handle nested hashes
    def format_keys(hash, key_format_method)
      return hash unless key_format_method

      hash.each_with_object({}) do | (k, v), result |
        new_key = k.send(key_format_method)
        result[new_key] = v
      end
    end
  end
end
