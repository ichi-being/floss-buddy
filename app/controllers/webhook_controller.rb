class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  protect_from_forgery except: :callback

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      # テキストメッセージが送られた場合の処理
      if event.is_a?(Line::Bot::Event::Message) && event.type == Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text'] # ユーザーからのテキストをそのまま返す
        }
        client.reply_message(event['replyToken'], message)
      end
    }

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end
