# == Schema Information
#
# Table name: floss_records
#
#  id                :bigint           not null, primary key
#  consecutive_count :integer          default(0)
#  record_date       :date             not null
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

  validates :record_date, presence: true
  validate :date_is_yesterday_or_today
  validates :consecutive_count, numericality: { greater_than_or_equal_to: 0 }

  private

  def date_is_yesterday_or_today
    if record_date.present? && record_date != Date.today && record_date != Date.yesterday
      errors.add(:record_date, :record_date_must_be)
    end
  end
end
