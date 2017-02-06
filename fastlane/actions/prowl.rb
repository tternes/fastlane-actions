module Fastlane
  module Actions

    class ProwlAction < Action
      def self.run(params)
        
        require "json"
        require "net/http"
        require "uri"

        uri = URI('https://api.prowlapp.com/publicapi/add')
        response = Net::HTTP.post_form(uri, {
          'apikey' => "#{params[:api_key]}",
          'application' => "#{params[:application]}",
          'event' => "#{params[:event]}",
          'description' => "#{params[:description]}",
          'priority' => "0"
        })

        if response.code == "200"
          UI.success "Service returned successfully"
        else
          UI.message "Status code: " + response.code
          response.each_header do |header_name, header_value|
            UI.error header_name + ":" + header_value
          end
          UI.message response.body
          UI.error "unexpected response from Prowl"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Sends messages to Prowl"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "PROWL_API_KEY",
                                       description: "Prowl API Key",
                                       verify_block: proc do |value|
                                          raise "No api key for Prowl given, pass using `api_token: 'value'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :application,
                                       env_name: "PROWL_APPLICATION",
                                       description: "Application for Prowl notification",
                                       verify_block: proc do |value|
                                          raise "No application for Prowl given, pass using `application: 'value'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :event,
                                       env_name: "PROWL_EVENT",
                                       description: "Event for Prowl notification",
                                       verify_block: proc do |value|
                                          raise "No event for Prowl given, pass using `event: 'value'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: "PROWL_DESCRIPTION",
                                       description: "Description for Prowl notification",
                                       verify_block: proc do |value|
                                          raise "No description for Prowl given, pass using `description: 'value'`".red unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.authors
        ["thaddeus"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
