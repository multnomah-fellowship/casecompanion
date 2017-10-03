# frozen_string_literal: true

class MailchimpCsvsController < ApplicationController
  before_action :require_admin!
  before_action :set_generator

  def show
    out_io = StringIO.new
    @generator.generate_by_name(params[:id], out_io)

    render plain: out_io.tap(&:rewind).read
  end

  private
  
  def set_generator
    @generator = MailchimpCsvGenerator.new(
      logger: Rails.logger,
      local_crimes: LocalCrimesInPostgres.new,
    )
  end
end
