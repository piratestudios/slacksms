# SlackSMS

A bot that allows you to chat to people via SMS inside of Slack.

## Note

This was very quickly hacked together over a day, and has no tests. This will hopefully be improved when I have some spare time.

# Deployment

This bot can be deployed directly to Heroku. Standard integration is very simple, just set the following URL as
the Twilio incoming SMS webhook URL: `http://<app-name>.herokuapp.com/incoming`. It supports either GET or POST requests. It works only with a Twilio messaging service, with which you'll need to associate at least one phone number.

Create a custom integration bot in Slack and set the API key and channel in env vars.

# Usage

SMS messages will automatically be posted to the configured channel. To reply, use one of the following:

* `@smsbot send +447911111111 Example reply message, hello!`
* `@smsbot reply +447911111111 Example reply message, hello!`
* `@smsbot +447911111111 Example reply message, hello!` <-- so very lazy

# Extra information

You can attach extra information to the request by forwarding the incoming SMS webhook from your own server using TwiML.
Here's an example in Rails. You currently need to use the URLcrypt library to secure the extra content, however this could
be changed/optional in future.

```
class WebhooksController < ApplicationController
  def sms
    url = URI.parse("http://<app-name>.herokuapp.com/incoming")
    from_phone_number = params['From']

    if from_phone_number.present?
      user = User.find_by(phone_number: PhonyRails.normalize_number(from_phone_number))

      if user.present?
        extra = [
          {
            title: "Name",
            text: user.full_name
          },
          {
            title: "Email",
            text: user.email
          }
        ]

        url.query = URI.encode_www_form({ extra: URLcrypt.encrypt(JSON.generate(extra)) })
      end
    end

    render xml: Twilio::TwiML::Response.new { |r|
      r.Redirect url
    }.text
  end
end
```

## Environment Variables

The following env vars need to be set.
```
SLACK_API_TOKEN
  _your Slack API token_
  
SLACK_CHANNEL
  _i.e. "#support"_
  
SMSBOT_SECRET_KEY
  _used for secure data additions from your own app_
  
TWILIO_ACCOUNT_SID
  _your Twilio account SID_
  
TWILIO_AUTH_TOKEN
  _your Twilio auth token_
  
TWILIO_MESSAGING_SERVICE_SID
  _supports using a messaging service only, due to automatic region detection_
```

# Developing locally

1. Clone the repo.
2. `bundle install`
3. Create an .env file containing the same values [specified in heroku](https://dashboard.heroku.com/apps/pirate-studios-smsbot/settings).
4. `rackup` to start server.
5. Use [ngrok](https://ngrok.com/) or similar to reverse-proxy the port to the outside world.
6. Create a [slack bot](https://pirate-studios.slack.com/apps/A0F7YS25R-bots) or re-use Brittany's `sms-test-bot`.
7. `git push` to master to deploy to heroku.
