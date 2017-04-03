class OffenderSearchCache < ActiveRecord::Base
  serialize :data, JSON

  AGE_LIMIT = 1.day

  default_scope { where('updated_at > ?', AGE_LIMIT.ago) }

  def self.purge_all!
    update_all(updated_at: AGE_LIMIT - 1)
  end
end
