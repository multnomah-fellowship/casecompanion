# frozen_string_literal: true

class Admin::DigitalVrnsController < ApplicationController
  before_action :require_admin!

  def index
    @vrns = CourtCaseSubscription.last(10)
  end

  def show
    vrn = CourtCaseSubscription.find(params[:id])

    pdf = RightsPdfGenerator
      .new(vrn)
      .generate

    send_data pdf.data, filename: pdf.filename, type: 'application/pdf'
  end
end
