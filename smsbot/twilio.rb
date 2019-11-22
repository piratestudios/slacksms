require 'twilio-ruby'

module SMSBot
  class SMS
    class << self
      def client
        @client ||= Twilio::REST::Client.new
      end

      def messaging_service_sid
        ENV['TWILIO_MESSAGING_SERVICE_SID']
      end

      def send(to: "", body: "", &block)
        client.messages.create(
          messaging_service_sid: messaging_service_sid,
          to: to.gsub(/[^\d]/, ''),
          body: body
        )

        block.call
      end
    end
  end
end
