module Fastlane
  module Actions
    module SharedValues
      BUILDNUMBER_XYZ_CURRENT_BUILD = :BUILDNUMBER_XYZ_CURRENT_BUILD
      BUILDNUMBER_XYZ_INCREMENT = :BUILDNUMBER_XYZ_INCREMENT
    end

    class BuildnumberXyzAction < Action
      def self.run(params)
        
        require "json"
        require "net/http"
        require "uri"

        buildnumber_xyz_host = "http://buildnumber.xyz"
        build_id = params[:build_id]
        increment = params[:increment]
        UI.message "build_id: #{build_id}"
        UI.message "increment: #{increment}"

        uri = URI.parse("#{buildnumber_xyz_host}/builds/#{build_id}")
        http = Net::HTTP.new(uri.host, uri.port)

        should_request = false
        current = Actions.lane_context[SharedValues::BUILDNUMBER_XYZ_CURRENT_BUILD]
        if current.nil?
          should_request = true
        end
        
        if params[:increment]
          UI.message "Requesting next version for build #{build_id}"
          request = Net::HTTP::Put.new(uri.request_uri)
        else
          
          UI.message "Requesting current version for build #{build_id}"
          request = Net::HTTP::Get.new(uri.request_uri)
        end

        response = http.request(request)

        if should_request
          if response.code == "200"
            result = JSON.parse(response.body)
            current = result["current"]
          
            UI.success "Service returned version #{current}"
          else
            UI.error "Status code: " + response.code
            response.each_header do |header_name, header_value|
              UI.error header_name + ":" + header_value
            end
            UI.important response.body
            UI.error "unexpected response from buildnumber.xyz"
          end
        else
          UI.message "Skipping request to service #{current}"
        end
        
        Actions.lane_context[SharedValues::BUILDNUMBER_XYZ_CURRENT_BUILD] = current
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Manage build numbers across machines, clusters, or even operating systems"
      end

      def self.details
        "Interact with the buildnumber.xyz service to manage globally-incrementing build numbers."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_id,
                                       env_name: "BUILDNUMBER_XYZ_BUILD_ID",
                                       description: "Build Identifier",
                                       verify_block: proc do |value|
                                          raise "No Build ID for buildnumber_xyz given, pass using `build_id: 'id'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :increment,
                                       env_name: "BUILDNUMBER_XYZ_INCREMENT",
                                       description: "Increment the current build number instead of just fetching it",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['BUILDNUMBER_XYZ_CURRENT_BUILD', 'The current build number for the last build']
        ]
      end

      def self.return_value
        "The current build number (either without changing or after incrementing)"
      end

      def self.authors
        ["@tternes"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
