module SMSBot
  module Commands
    class Reply < SlackRubyBot::Commands::Base
      help do
        title 'reply'
        desc 'reply to a message'
        long_desc 'command format: reply +447911111111 Hello there Bobby Tables, how can I help?'
      end

      match %r{
          ^\p{Z}*                               # some white space
          (?<bot><\@[\w\d]+>)                   # bot identifier e.g. <@UQXACP1JT>
          \p{Z}*                                # optional spaces before command
          (?<command>reply\p{Z}+|send\p{Z}+)?   # "reply" or "send", but this is now optional, followed by whitespace
          (?<to>\+?[\d]+|<tel:\+?\d+\|\+?\d+>)  # phone number, either as plain-text or as a <tel:1234|4321>
          \p{Z}+                                # at least one space
          (?<message>.+)                        # message of one or more characters
        }x do |client, data, match|
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
