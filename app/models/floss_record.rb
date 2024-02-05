# == Schema Information
#
# Table name: floss_records
#
#  id                :bigint           not null, primary key
#  consecutive_count :integer          default(0)
#  record_date       :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_floss_records_on_user_id                  (user_id)
#  index_floss_records_on_user_id_and_record_date  (user_id,record_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class FlossRecord < ApplicationRecord
  belongs_to :user

  validates :record_date, uniqueness: { scope: :user_id }
  validates :consecutive_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_save :update_consecutive_count

  private

  # 実施記録を保存する前に、連続実施日数を更新する
  def update_consecutive_count
    last_record = user.floss_records.order(record_date: :desc).first

    if last_record && (record_date - last_record.record_date).abs == 1
      # 前回の記録から前後1日だけ空いた場合、連続実施日数を1増やす
      self.consecutive_count = last_record.consecutive_count + 1
    else
      # 2日以上空いた場合、連続実施日数を1にリセット
      self.consecutive_count = 1
    end
  end
end
