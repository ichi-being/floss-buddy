class WeeklyFlossSummaryJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ユーザーごとに直近1週間のフロス実施日数を合計
    User.find_each do |user|
      total_floss_days = user.floss_records.where('record_date >= ?', 1.week.ago).count

      # フロス記録がある場合とない場合で異なるメッセージを送信
      if total_floss_days > 0
        send_positive_summary(user.line_user_id, total_floss_days)
      else
        send_encouragement_message(user.line_user_id)
      end
    end
  end

  private

  def send_positive_summary(line_user_id, total_floss_days)
    # フロス記録がある場合は、その週のフロス実施日数を送信
    message = {
        "type": 'text',
        "text": "今週は#{total_floss_days}日フロスをしたよ。\n素晴らしい習慣だね！\n来週もがんばろう！",
    }

    line_client.push_message(line_user_id, message)
  end

  def send_encouragement_message(line_user_id)
    # フロス記録がない場合は、励ましのメッセージを送信
    message = {
        "type": "text",
        "text": "今週はフロスできなかったね。\n大丈夫、来週からまた一緒にがんばろう！"
    }

    line_client.push_message(line_user_id, message)
  end

  def line_client
    LineBotClient.client
  end
end
