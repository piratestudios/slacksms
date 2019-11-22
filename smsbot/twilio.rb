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
        # Slack started formatting phone numbers with a + prefix as
        # <tel:+447xxxxxxxxx|+447xxxxxxxxx> so use a regex to capture
        # the first set of numbers.
        to = to[/(\d+)/]

        client.messages.create(
          messaging_service_sid: messaging_service_sid,
          to: to,
          body: body
        )

        block.call
      end
    end
  end
end
