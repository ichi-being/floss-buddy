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
