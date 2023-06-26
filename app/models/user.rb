# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :icon
  validates :icon, content_type: ['image/png', 'image/jpeg', 'image/gif']
end
