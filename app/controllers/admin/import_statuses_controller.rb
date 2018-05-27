# frozen_string_literal: true

class Admin::ImportStatusesController < ApplicationController
  before_action :require_admin!

  def show
    @lines = SqlTableLogger
      .new(ENV['LOCAL_ATTORNEY_MANAGER_DATABASE_URL'], 'attorney_manager_import_log')
      .lines
  end
end
