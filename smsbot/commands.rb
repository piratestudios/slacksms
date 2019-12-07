module SMSBot
  module Commands
    class Reply < SlackRubyBot::Commands::Base
      help do
        title 'reply'
        desc 'reply to a message'
        long_desc 'command format: reply +447911111111 Hello there Bobby Tables, how can I help?'
      end

      match /^\p{Z}*(?<bot><\@[\w\d]+>)\p{Z}*(?<command>reply\p{Z}+|send\p{Z}+)?(?<to>\+?[\d]+|<tel:\+?\d+\|\+?\d+>)\p{Z}+(?<message>.*)/ do |client, data, match|
        #puts "data: #{data.inspect}\n"

        #puts "data.text:   #{data.text}"
        #puts "match:       #{match.inspect}"

        begin
          SMSBot::SMS.send(to: match['to'], body: match['message']) do
            client.say(
              channel: data.channel,
              text: ":heavy_check_mark: Message sent to `#{match['to']}`:\n\n```#{match['message']}```"
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
