module SMSBot
  module Commands
    class Reply < SlackRubyBot::Commands::Base
      help do
        title 'reply'
        desc 'reply to a message'
        long_desc 'command format: reply +447911111111 Hello there Bobby Tables, how can I help?'
      end

      command 'reply', 'send' do |client, data, match|
        reference, message = match['expression'].split(' ', 2)
        client.typing(channel: data.channel)

        begin
          SMSBot::SMS.send(to: reference, body: message) do
            client.say(
              channel: data.channel,
              text: ":heavy_check_mark: Message sent!"
            )
          end
        rescue Exception => ex
          client.say(
            channel: data.channel,
            text: ":x: Failed to send message due to an error: #{ex.message}"
          )

          raise ex
        end
      end
    end
  end
end
