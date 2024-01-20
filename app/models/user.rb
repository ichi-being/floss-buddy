class User < ApplicationRecord
  validates :line_user_id, presence: true, uniqueness: true
  validates :display_name, presence: true
end
