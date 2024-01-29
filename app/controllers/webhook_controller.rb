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
      when 'フロスしたよ！'
        message = {
          type: 'template',
          altText: "ナイスフロス！いつの記録をつける？",
          template: {
            type: 'buttons',
            text: "ナイスフロス！\nいつの記録をつける？",
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

      # フロス記録の保存に成功した場合のみ特別メッセージを追加
      if result[:success]
        consecutive_days = user.floss_records.last.consecutive_count
        special_message = select_response_message(consecutive_days)
        response_message_text = "#{result[:message]}\n#{special_message}"
      else
        response_message_text = result[:message]
      end

      response_message = { type: 'text', text: response_message_text }

      # 成功した場合のみ画像メッセージを送信
      if result[:success]
        image_url = select_image_url(consecutive_days)
        image_message = { type: 'image', originalContentUrl: image_url, previewImageUrl: image_url }
        client.reply_message(event['replyToken'], [response_message, image_message])
      else
        client.reply_message(event['replyToken'], response_message)
      end
    end
  end

  def select_response_message(consecutive_days)
    case consecutive_days
    when 7 then "ナイスフロス！\n1週間のフロス継続エライ！"
    when 14 then "ナイスフロス！\n2週間続けれたね。習慣化の道も半分過ぎたよ。"
    when 21 then "ナイスフロス！\n3週間の継続エクセレント！ほぼ習慣化されたも同然だね。"
    when 28 then "ナイスフロス！\n4週間の継続達成おめでとう！定期的に歯科検診も受けて、お口の健康を保っていこう！"
    else "ナイスフロス！\n毎日の習慣で素敵な笑顔を保とう！"
    end
  end

  def select_image_url(consecutive_count)
    case consecutive_count
    when 1 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_1.png"
    when 2 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_2.png"
    when 3 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_3.png"
    when 4 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_4.png"
    when 5 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_5.png"
    when 6 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_6.png"
    when 7..13 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_7_13.png"
    when 14..20 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_14_20.png"
    when 21..27 then "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_21_27.png"
    else
      "https://floss-buddy-message.s3.ap-northeast-1.amazonaws.com/achievement_images/Day_28.png"
    end
  end

  def find_or_create_user(line_user_id)
    User.find_or_create_by(line_user_id: line_user_id)
  end

  def create_floss_record(user, record_date)
    floss_record = user.floss_records.new(record_date: record_date)
    if floss_record.save
      { success: true, message: "#{record_date}の記録を保存したよ。" }
    else
      { success: false, message: "#{record_date}の記録は前にしているよ。フロスが習慣になってきているね。" }
    end
  end
end
