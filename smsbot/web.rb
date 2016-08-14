require 'sinatra/base'

module SMSBot
  class Web < Sinatra::Base
    get '/' do
      "Beep boop"
    end

    incoming = lambda do
      id, from, to, body = params.values_at('MessageSid', 'From', 'To', 'Body')
      additional_info = JSON.parse(URLcrypt.decrypt(params['extra'])) unless params['extra'].nil?

      attachments = [
        {
          title: "Message",
          text: body
        },
        {
          title: "From",
          text: from
        }
      ].concat(additional_info || [])

      client.chat_postMessage(
        channel: channel,
        text: ":mailbox_with_mail: New SMS message received on *#{to}*",
        attachments: attachments,
        as_user: true
      )

      status 200
    end

    get '/incoming', &incoming
    post '/incoming', &incoming

    private

    def client
      @client ||= Slack::Web::Client.new
    end

    def channel
      ENV['SLACK_CHANNEL']
    end
  end
end
