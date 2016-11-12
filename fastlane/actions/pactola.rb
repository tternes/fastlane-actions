module Fastlane
  module Actions
    module SharedValues
      PACTOLA_CUSTOM_VALUE = :PACTOLA_CUSTOM_VALUE
    end

    class PactolaAction < Action
      def self.run(params)
        
        require "json"
        require "net/http"
        require "uri"

        UI.message "Using API Token: #{params[:device_token]}"

        device_url = "https://pactola.io/#{params[:device_token]}/notification"
        UI.message "device_url: #{device_url}"

        uri = URI.parse(device_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = {title: "#{params[:title]}", message: "#{params[:message]}"}.to_json
        response = http.request(request)

        if response.code == "202"
          UI.success "Service returned 202 successfully"
        else
          UI.message "Status code: " + response.code
          response.each_header do |header_name, header_value|
            Helper.log.error header_name + ":" + header_value
          end
          UI.message response.body
          UI.error "unexpected response from pactola.io"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Sends messages to Pactola.io"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :device_token,
                                       env_name: "PACTOLA_DEVICE_TOKEN",
                                       description: "Device Token for Pactola",
                                       verify_block: proc do |value|
                                          raise "No device token for Pactola given, pass using `device_token: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: "PACTOLA_TITLE",
                                       description: "Title for Pactola notification",
                                       optional: true,
                                       verify_block: proc do |value|
                                          raise "No notification title for Pactola given, pass using `title: 'value'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "PACTOLA_MESSAGE",
                                       description: "Message for Pactola notification",
                                       verify_block: proc do |value|
                                          raise "No notification message for Pactola given, pass using `message: 'value'`".red unless (value and not value.empty?)
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
