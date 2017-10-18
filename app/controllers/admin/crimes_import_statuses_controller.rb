# frozen_string_literal: true

class Admin::CrimesImportStatusesController < ApplicationController
  before_action :require_admin!

  def show
    local_crimes = LocalCrimesInPostgres.new
    @status = local_crimes.status_updates

    render json: @status
  end
end
