require "http/client"
require "json"
require "uri"

module Elasticsearch
  module API
    module Common
      module Actions; end

      module Constants
        DEFAULT_SERIALIZER = JSON
  
        COMMON_PARAMS = [
          :ignore,                        # Client specific parameters
          :index, :type, :id,             # :index/:type/:id
          :body,                          # Request body
          :node_id,                       # Cluster
          :name,                          # Alias, template, settings, warmer, ...
          :field                          # Get field mapping
        ]
    
        COMMON_QUERY_PARAMS = [
          :ignore,                        # Client specific parameters
          :format,                        # Search, Cat, ...
          :pretty,                        # Pretty-print the response
          :human,                         # Return numeric values in human readable format
          :filter_path                    # Filter the JSON response
        ]
  
        HTTP_GET          = "GET"
        HTTP_HEAD         = "HEAD"
        HTTP_POST         = "POST"
        HTTP_PUT          = "PUT"
        HTTP_DELETE       = "DELETE"
        UNDERSCORE_SEARCH = "_search"
        UNDERSCORE_ALL    = "_all"
      end

      class Response
        getter :status, :body, :headers
        def initialize(@status : Int32, @body : String, @headers : HTTP::Headers)
        end
      end

      class JsonResponse
        getter :status, :body, :headers
        def initialize(@status : Int32, @body : JSON::Any, @headers : HTTP::Headers)
        end
      end

      class Client
        def initialize(@settings : Hash(Symbol, String | Int32)) 
        end

        def perform_request(method, path, params={} of String => String, body={} of String => String | Nil) 

          # normalize params to string
          new_params = {} of String => String
          params.each do |k,v|
            if !!v == v
              new_params[k.to_s] = ""
            else
              new_params[k.to_s] = v.to_s
            end
          end
          
          final_params = HTTP::Params.encode(new_params)

          if !body.nil?
            post_data = body.to_json
          else
            post_data = nil
          end
          
          @settings[:proto] ||= "http"
          client = HTTP::Client.new(uri: URI.new(@settings[:proto].to_s, @settings[:host].to_s, @settings[:port].to_i))
          client.basic_auth(@settings[:username], @settings[:password]) if @settings.has_key?(:username)

          if method == "GET"
            endpoint = "/#{path}?#{final_params}"
            response = client.get(endpoint, body: post_data, headers: HTTP::Headers{"Content-Type" => "application/json"})
          elsif method == "POST"
            endpoint = "/#{path}"
            response = client.post(endpoint, body: post_data)
          elsif method == "PUT"
            endpoint = "/#{path}"
            response = client.put(endpoint, body: post_data)
          elsif method == "DELETE"
            endpoint = "/#{path}?#{final_params}"
            response = client.delete(endpoint)
          elsif method == "HEAD"
            endpoint = "/#{path}"
            response = client.head(endpoint)
          end

          result = response.as(HTTP::Client::Response)
         
          if result.headers["Content-Type"].includes?("application/json") && method != "HEAD"
            final_response = JsonResponse.new result.status_code, JSON.parse(result.body), result.headers
          else
            final_response = Response.new result.status_code, result.body.as(String), result.headers
          end
          
          final_response
          
        end
      end
    end
  end
end
