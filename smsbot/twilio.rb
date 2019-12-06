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
        puts "[orig]   To: '#{to}'"
        to = to[/(\d+)/]
        puts "[parsed] To: '#{to}'"

        # Do the same for the body, stripping as many <tel:+1234|+1234>
        # that occur.
        puts "[orig]   Body: '#{body}'"
        body.gsub!(/<tel:\+\d+\|(\+\d+)>/, '\1')
        # Strip website tags <http://pirate.com/piratelive@pirate.com/piratelive>
        # Strip website tags <http://pirate.com/piratelive|pirate.com/piratelive>
        body.gsub!(/<https?:\/\/[\w\.\/]+[\@|]([\w\.\/]+)>/, '\1')
        body.gsub!(/<(https?:\/\/.*)>/, '\1') # not sure why...

        # Strip mailto tags <mailto:pete2.black@pirate.co.uk|pete2.black@pirate.co.uk>
        body.gsub!(/<mailto:[\w\d\.\@]+\|([\w\d\.\@]+)>/, '\1')
        puts "[parsed] Body: '#{body}'\n"

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
