class TimelineEvent < ApplicationRecord
  belongs_to :actor,             polymorphic: true, optional: true
  belongs_to :subject,           polymorphic: true, optional: true
  belongs_to :secondary_subject, polymorphic: true, optional: true

  scope :for_node, ->(node) do
    where(<<-SQL, {:id => node.id, :klass => node.class.name})
      (subject_id = :id AND subject_type = :klass) OR
      (secondary_subject_id = :id AND secondary_subject_type = :klass)
    SQL
  end
  scope :recent, ->(n = 10) { order('created_at DESC, id DESC').limit(n) }

  def subject_name
    subject ? subject.name : "A #{subject_type.downcase}"
  end

  def secondary_name
    secondary_subject ? secondary_subject.name : "a #{secondary_subject_type.underscore.humanize.downcase}"
  end

  def object_type
    (secondary_subject_type || subject_type).to_s.downcase
  end

  def action
    "was #{event_type.tr('_', ' ')}"
  end
end
