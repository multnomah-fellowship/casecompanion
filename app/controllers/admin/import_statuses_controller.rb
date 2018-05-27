# frozen_string_literal: true

class Admin::ImportStatusesController < ApplicationController
  before_action :require_admin!

  def show
    @revision = load_revision
    @lines = logger_lines
    @deploy_time = deploy_time
  end

  private

  def load_revision
    File.read(Rails.root.join('REVISION'))
  rescue
    return 'master'
  end

  def logger_lines
    SqlTableLogger
      .new(ENV['LOCAL_ATTORNEY_MANAGER_DATABASE_URL'], 'attorney_manager_import_log')
      .lines
  rescue
    []
  end

  def deploy_time
    root = Rails.root.basename.to_s
    return 'Unknown' if root !~ /^\d+$/

    year = root[0..3].to_i
    month = root[4..5].to_i
    day = root[6..7].to_i
    hour = root[8..9].to_i
    minute = root[10..11].to_i
    second = root[12..13].to_i

    Time.zone
      .local(year, month, day, hour, minute, second)
      .strftime('%A %B %-d, %Y at %-I:%M %P')
  rescue
    return 'Unknown'
  end
end
