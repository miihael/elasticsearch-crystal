module Elasticsearch
  module API
    module Indices
      module Actions

        # Create an index.
        #
        # Pass the index `settings` and `mappings` in the `:body` attribute.
        #
        # @example Create an index with specific settings, custom analyzers and mappings
        #
        #     client.indices.create index: 'test',
        #                           body: {
        #                             settings: {
        #                               index: {
        #                                 number_of_shards: 1,
        #                                 number_of_replicas: 0,
        #                                 'routing.allocation.include.name' => 'node-1'
        #                               },
        #                               analysis: {
        #                                 filter: {
        #                                   ngram: {
        #                                     type: 'nGram',
        #                                     min_gram: 3,
        #                                     max_gram: 25
        #                                   }
        #                                 },
        #                                 analyzer: {
        #                                   ngram: {
        #                                     tokenizer: 'whitespace',
        #                                     filter: ['lowercase', 'stop', 'ngram'],
        #                                     type: 'custom'
        #                                   },
        #                                   ngram_search: {
        #                                     tokenizer: 'whitespace',
        #                                     filter: ['lowercase', 'stop'],
        #                                     type: 'custom'
        #                                   }
        #                                 }
        #                               }
        #                             },
        #                             mappings: {
        #                               document: {
        #                                 properties: {
        #                                   title: {
        #                                     type: 'multi_field',
        #                                     fields: {
        #                                         title:  { type: 'string', analyzer: 'snowball' },
        #                                         exact:  { type: 'string', analyzer: 'keyword' },
        #                                         ngram:  { type: 'string',
        #                                                   index_analyzer: 'ngram',
        #                                                   search_analyzer: 'ngram_search'
        #                                         }
        #                                     }
        #                                   }
        #                                 }
        #                               }
        #                             }
        #                           }
        #
        # @option arguments [String] :index The name of the index (*Required*)
        # @option arguments [Hash] :body Optional configuration for the index (`settings` and `mappings`)
        # @option arguments [Boolean] :update_all_types Whether to update the mapping for all fields
        #                                               with the same name across all types
        # @option arguments [Number] :wait_for_active_shards Wait until the specified number of shards is active
        # @option arguments [Time] :timeout Explicit operation timeout
        # @option arguments [Boolean] :master_timeout Timeout for connection to master
        #
        # @see http://www.elasticsearch.org/guide/reference/api/admin-indices-create-index/
        #
        def create(arguments={} of Symbol => String)
          if !arguments.has_key?(:index)
            raise ArgumentError.new("Required argument 'index' missing")
          end
          valid_params = [
            :timeout,
            :master_timeout,
            :update_all_types,
            :wait_for_active_shards
          ]

          method = "PUT"
          
          path   = Utils.__pathify Utils.__escape(arguments[:index])
          
          if arguments.has_key? :body
            body = arguments.delete(:body)
          else
            body = nil
          end

          params = Utils.__validate_and_extract_params arguments, valid_params

          perform_request(method, path, params, body).body
        end
      end
    end
  end
end
