class UtmAttribution < ApplicationRecord
  FIELDS = %w[utm_campaign utm_medium utm_source utm_content]

  def self.new_from_params(params)
    new(params.permit(*FIELDS).slice(*FIELDS))
  end

  def self.first_or_create_from_params(params)
    where(params.slice(*FIELDS)).first_or_create
  end
end
