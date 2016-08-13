require 'twilio-ruby'

module SMSBot
  class SMS
    class << self
      def client
        @client ||= Twilio::REST::Client.new
      end

      def send(to: "", body: "", &block)
        from = phone_number_for(to)

        client.messages.create(
          from: from,
          to: to,
          body: body
        )

        block.call(from)
      end

      private

      # Find the best matching phone number from a target number
      #
      # @return [String]

      def phone_number_for(target)
        numbers = ENV['TWILIO_PHONE_NUMBERS'].split(',').map(&:strip)
        numbers.first #TODO
      end
    end
  end
end
