# SlackSMS

A bot that allows you to chat to people via SMS inside of Slack.

## Note

This was very quickly hacked together over a day, and has no tests. This will hopefully be improved when I have some spare time.

# Deployment

This bot can be deployed directly to Heroku. Standard integration is very simple, just set the following URL as
the Twilio incoming SMS webhook URL: `http://<app-name>.herokuapp.com/incoming`. It supports either GET or POST requests. It works only with a Twilio messaging service, with which you'll need to associate at least one phone number.

Create a custom integration bot in Slack and set the API key and channel in env vars.

# Usage

SMS messages will automatically be posted to the configured channel. To reply, use the following format:

`@smsbot reply +447911111111 Example reply message, hello!`

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
