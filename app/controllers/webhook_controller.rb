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

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        handle_message_event(event)
      when Line::Bot::Event::Postback
        handle_postback_event(event)
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end

  def handle_message_event(event)
    case event.type
    when Line::Bot::Event::MessageType::Text
      case event.message['text']
      when 'フロス記録をつける'
        message = {
          type: 'template',
          altText: 'ナイスフロス！いつの記録をつけますか？',
          template: {
            type: 'buttons',
            text: 'ナイスフロス！いつの記録をつけますか？',
            actions: [
              {
                type: 'postback',
                label: '昨日',
                data: 'date=yesterday'
              },
              {
                type: 'postback',
                label: '今日',
                data: 'date=today'
              }
            ]
          }
        }
        client.reply_message(event['replyToken'], message)
      end
    end
  end

  def handle_postback_event(event)
    data = Rack::Utils.parse_nested_query(event['postback']['data'])
    record_date = case data['date']
                  when 'yesterday'
                    Time.zone.yesterday
                  when 'today'
                    Time.zone.today
                  end

    if record_date
      user = find_or_create_user(event['source']['userId'])
      result = create_floss_record(user, record_date) if user

      # テキストメッセージ
      response_message = { type: 'text', text: result[:message] }
      # 画像メッセージ
      image_message = {
        type: 'image',
        originalContentUrl: 'https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/LINE_icon.png',
        previewImageUrl: 'https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/LINE_icon.png'
      }

      # テキストと画像のメッセージを配列で送信
      client.reply_message(event['replyToken'], [response_message, image_message])
    end
  end

  def find_or_create_user(line_user_id)
    User.find_or_create_by(line_user_id: line_user_id)
  end

  def create_floss_record(user, record_date)
    floss_record = user.floss_records.new(record_date: record_date)
    if floss_record.save
      { success: true, message: "#{record_date}のフロス記録を保存したよ。" }
    else
      { success: false, message: floss_record.errors.full_messages.join(", ") }
    end
  end
end
