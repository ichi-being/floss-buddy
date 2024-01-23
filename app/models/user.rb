# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  display_name :string           not null
#  image        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  line_user_id :string           not null
#
class User < ApplicationRecord
  has_many :floss_records, dependent: :destroy

  validates :line_user_id, presence: true, uniqueness: true
  validates :display_name, presence: true
end
