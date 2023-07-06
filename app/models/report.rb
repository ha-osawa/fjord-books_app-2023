# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :mentionings, class_name: 'Mention', foreign_key: :mentioned_report_id, inverse_of: :mentioned_report, dependent: :destroy
  has_many :mentioneds, class_name: 'Mention', foreign_key: :mentioning_report_id, inverse_of: :mentioning_report, dependent: :destroy

  has_many :mentioning_reports, through: :mentionings, source: :mentioning_report
  has_many :mentioned_reports, through: :mentioneds, source: :mentioned_report

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def mentioning?
    content.match?(%r{http://localhost:3000/reports/[0-9]+}) || mentionings
  end

  def extract_mentioning_report_ids
    content.scan(%r{http://localhost:3000/reports/[0-9]+}).map do |uri|
      URI.parse(uri).path.match(%r{[^/reports/][0-9]*}).to_s.to_i
    end
  end

  def create_mentioning_reports
    extract_mentioning_report_ids.map do |mentioning_id|
      mentionings.new(mentioning_report_id: mentioning_id)
    end
  end

  def update_mentioning_reports
    update_mentioning_report_ids = extract_mentioning_report_ids - mentionings.pluck(:mentioning_report_id)
    mentionings.where.not(mentioning_report_id: extract_mentioning_report_ids).destroy_all
    update_mentioning_report_ids.map do |mentioning_id|
      mentionings.new(mentioning_report_id: mentioning_id)
    end
  end

  def save_mentions
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless save
      if mentioning?
        create_mentioning_reports.each do | mentioning_report |
          raise ActiveRecord::Rollback unless mentioning_report.save
        end
      end
      true
    end
  end

  def update_mentions(report_params)
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless update(report_params)
      if mentioning?
        update_mentioning_reports.each do | mentioning_report |
          raise ActiveRecord::Rollback unless mentioning_report.save
        end
      end
      true
    end
  end
end
