# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :mentionings, class_name: "Mention", foreign_key: :mentioned_report_id, dependent: :destroy
  has_many :mentioneds, class_name: "Mention", foreign_key: :mentioning_report_id, dependent: :destroy

  has_many :mentioning_reports, through: :mentionings, source: :mentioning_report
  has_many :mentioned_reports, through: :mentioneds,  source: :mentioned_report

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end
end
