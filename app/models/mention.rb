class Mention < ApplicationRecord
  belongs_to :mentioning_report, class_name: "Report"
  belongs_to :mentioned_report, class_name: "Report"

  validates :mentioning_report, presence: true, uniqueness: { scope: :mentioned_report }
  validates :mentioned_report, presence: true, uniqueness: { scope: :mentioning_report }
end
