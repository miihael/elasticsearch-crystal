module Elasticsearch
  module API
    module Actions

      # Retrieve an indexed script from Elasticsearch
      #
      # @option arguments [String] :id Template ID (*Required*)
      # @option arguments [Hash] :body The document
      #
      # @see http://www.elasticsearch.org/guide/en/elasticsearch/reference/master/search-template.html
      #
      def get_template(arguments={} of Symbol => String)
        if !arguments.has_key?(:id)
          raise ArgumentError.new("Required argument 'id' missing")
        end]
        method = "GET"
        path   = "_search/template/#{arguments[:id]}"
        params = {} of String => String
        body   = arguments[:body]

        if arguments[:ignore].includes?(404)
          Utils.__rescue_from_not_found { perform_request(method, path, params, body).body }
        else
          perform_request(method, path, params, body).body
        end
      end
    end
  end
end
