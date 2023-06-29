# frozen_string_literal: true
require 'uri'

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

  def mentioning?
    content.match?(/http:\/\/localhost:3000\/reports\/[0-9]+/) || self.mentionings
  end

  def extract_mentioning_report_id
    content.scan(/http:\/\/localhost:3000\/reports\/[0-9]+/).map do |uri|
      URI.parse(uri).path.match(/[^\/reports\/][0-9]*/).to_s.to_i
    end
  end

  def create_mentioning_reports
    self.extract_mentioning_report_id.each do |mentioning_id|
      self.mentionings.create!(mentioning_report_id: mentioning_id)
    end
  end

  def update_mantioning_reports
    update_mentioning_report_ids = self.extract_mentioning_report_id - self.mentionings.pluck(:mentioning_report_id)
    self.mentionings.where.not(mentioning_report_id: self.extract_mentioning_report_id ).destroy_all
    update_mentioning_report_ids.each do |mentioning_id|
      self.mentionings.create_or_find_by!(mentioning_report_id: mentioning_id)
    end
  end

  def execute_create_transaction
    ActiveRecord::Base.transaction do
      self.save!
      self.create_mentioning_reports if self.mentioning?
    end
    true
    rescue ActiveRecord::RecordInvalid
      false
  end

  def execute_update_transaction(report_params)
    ActiveRecord::Base.transaction do
      self.update!(report_params)
      self.update_mantioning_reports if self.mentioning?
    end
    true
    rescue ActiveRecord::RecordInvalid
      false
  end
end
