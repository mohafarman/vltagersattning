# lib/trafikverket_api.rb
require_relative '../../.trafikverket_key.rb'

require 'httparty'

module Vltagersattning
  class TrafikverketApi
    include HTTParty

    def initialize(signature_location, date)
      @authentication_key = $api_key
      @base_uri = "https://api.trafikinfo.trafikverket.se/v2/data.json"
      @headers = { 'Accept' => 'application/xml', 'Content-Type' => 'application/xml' }
      @signature_location = signature_location
      @date = date
    end

    def get_trains
      # TODO: Most important pieces of information is the following:
      # txtFromTime: '',    # tt:mm, planned: DeparturePlanned == From AdvertisedTimeAtLocation
      # txtToTime: '',  # tt:mm, planned: ArrivalPlanned == To AdvertisedTimeAtLocation
      # txtRealFromTime: '',  # tt:mm, actual: DepartureActual == From TimeAtLocation
      # txtRealToTime: '',    # tt:mm, actual: ArrivalActual == To TimeAtLocation; 00:00 if canceled?
      # Description: '',
      trains_delayed = get_trains_delayed
      trains_canceled = get_trains_canceled

      trains_delayed.merge(trains_canceled)
    end

    private

    def get_trains_delayed
      # TODO: Use <INCLUDE></INCLUDE> to only include necessary information
      # The NE excludes Vy trains which are not covered by VL
      # TIB is the owner of ARRIVA and TÅGAB
      body = "<REQUEST>\
        <LOGIN authenticationkey=\"#{@authentication_key}\"/>\
        <QUERY objecttype=\"TrainAnnouncement\" schemaversion=\"1.9\" orderby=\"AdvertisedTrainIdent\">\
          <FILTER>\
            <EQ name=\"ScheduledDepartureDateTime\" value=\"#{@date}\" />\
            <EQ name=\"LocationSignature\" value=\"#{@signature_location}\" />\
            <EQ name=\"ActivityType\" value=\"Avgang\" />\
            <EXISTS name=\"EstimatedTimeAtLocation\" value=\"true\" />\
            <NE name=\"Operator\" value=\"VY\" />\
          </FILTER>\
        </QUERY>\
      </REQUEST>"
      # Same as bove but in XML
      # <REQUEST>
      #   <LOGIN authenticationkey="demokey"/>
      #   <QUERY objecttype="TrainAnnouncement" schemaversion="1.9" orderby="AdvertisedTrainIdent">
      #     <FILTER>
      #       <EQ name="ScheduledDepartureDateTime" value="2024/04/28" />
      #       <EQ name="LocationSignature" value="Vå" />
      #       <EQ name="ActivityType" value="Ankomst" />
      #       <EXISTS name="EstimatedTimeAtLocation" value="true" />
      #       <NE name="Operator" value="VY" />
      #     </FILTER>
      #   </QUERY>
      # </REQUEST>

      response = self.class.post(@base_uri, headers: @headers, body: body)
      result = JSON.parse(response.body)

      handle_get_trains_delayed(result)
    end

    def get_trains_canceled
      # TODO: Use <INCLUDE></INCLUDE> to only include necessary information
      # The NE excludes Vy trains which are not covered by VL
      body = "<REQUEST>\
        <LOGIN authenticationkey=\"#{@authentication_key}\"/>\
        <QUERY objecttype=\"TrainAnnouncement\" schemaversion=\"1.9\" orderby=\"AdvertisedTrainIdent\">\
          <FILTER>\
            <EQ name=\"ScheduledDepartureDateTime\" value=\"#{@date}\" />\
            <EQ name=\"LocationSignature\" value=\"#{@signature_location}\" />\
            <EQ name=\"ActivityType\" value=\"Avgang\" />\
            <EQ name=\"Canceled\" value=\"true\" />\
            <NE name=\"Operator\" value=\"VY\" />\
          </FILTER>\
        </QUERY>\
      </REQUEST>"

      response = self.class.post(@base_uri, headers: @headers, body: body)
      result = JSON.parse(response.body)

      handle_get_trains_canceled(result)
    end

    def handle_get_trains_delayed(result)
      # Data processing function
      trains = result['RESPONSE']['RESULT'].each_with_object({}) do |result, trains_hash|
        result["TrainAnnouncement"].each do |announcement|
          key = announcement["AdvertisedTrainIdent"]
          begin
            # from_location_name = announcement["FromLocation"].map { |via| via["LocationName"] }
            # Locations the train is to visit
            via_to_location_names = announcement["ViaToLocation"].map { |via| via["LocationName"] }
            # Also get ToLocation (final destination)
            to_location_name = announcement["ToLocation"].map { |via| via["LocationName"] }
            # Append it to the list of locations the train is to visit
            # via_to_location_names = via_to_location_names + to_location_name
            via_to_location_names += to_location_name
            # via_to_location_names.unshift(@signature_location)

            value = {
              'DeparturePlanned' => announcement['AdvertisedTimeAtLocation'].sub(/([+-]\d+):(\d+)/, '\1\2'),
              'DepartureActual' => announcement['TimeAtLocation'].sub(/([+-]\d+):(\d+)/, '\1\2'),
              'ViaToLocation' => via_to_location_names,
              'Canceled' => false,
              'Operator' => announcement['Operator']
            }

            trains_hash[key] = value

            # TODO: Add the missing ViaToLocations
          rescue NoMethodError => e
            # Train is probably a cargo train
            # OBS. These are usually busses! And have one ToLocation, thus no ViaToLocation
            puts "Error: No ViaToLocation found. Probably bus. #{e}"
            # pp announcement
          end
        end
      end

      trains
    end

    def handle_get_trains_canceled(result)
      # Data processing function
      trains = result['RESPONSE']['RESULT'].each_with_object({}) do |result, trains_hash|
        result["TrainAnnouncement"].each do |announcement|
          key = announcement["AdvertisedTrainIdent"]
          begin
            # Locations the train is to visit
            via_to_location_names = announcement["ViaToLocation"].map { |via| via["LocationName"] }
            # Also get ToLocation (final destination)
            to_location_name = announcement["ToLocation"].map { |via| via["LocationName"] }
            # Append it to the list of locations the train is to visit
            via_to_location_names += to_location_name

            value = {
              "DeparturePlanned" => announcement["AdvertisedTimeAtLocation"].sub(/([+-]\d+):(\d+)/, '\1\2'),
              # No actual departure time because train was canceled
              'DepartureActual' => '00:00',
              'ViaToLocation' => via_to_location_names,
              'Canceled' => true,
              'Operator' => announcement["Operator"],
              'CompensationPercentage' => 100
            }

            trains_hash[key] = value

            # TODO: Add the missing ViaToLocations
          rescue NoMethodError => e
            # Train is probably a cargo train
            puts "Error: No ViaToLocation found. Probably cargo train. #{e}"
          end
        end
      end

      trains
    end

  end
end
