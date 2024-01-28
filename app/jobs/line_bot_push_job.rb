require 'line/bot'

class LineBotPushJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # LINE Bot API のクライアントを初期化
    client = Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    # メッセージの作成
    message = {
      type: 'text',
      text: 'テスト'
    }

    # 送信先のユーザーIDを取得
    User.find_each do |user|
      # user.line_user_id を使ってメッセージを送信
      client.push_message(user.line_user_id, message) if user.line_user_id.present?
    end
  end
end
