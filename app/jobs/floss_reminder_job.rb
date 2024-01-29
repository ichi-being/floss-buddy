class FlossReminderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # フロス実施記録を確認して通知が必要なユーザーを検索
    User.includes(:floss_records).find_each do |user|
      last_record_date = user.floss_records.order(record_date: :desc).first&.record_date
      next if last_record_date && last_record_date >= 3.days.ago.to_date

      send_reminder(user.line_user_id)
    end
  end

  private

  def send_reminder(line_user_id)
    client = LineBotClient.client

    message = {
      type: 'text',
      text: "体がかゆくなってきちゃった。\nフロスできれいにしてくれるかな？"
    }

    client.push_message(line_user_id, message)
  end
end