class OffendersController < ApplicationController
  OFFENDERS = [
    { sid: '1234' }
  ]

  def show
    @offender = params[:id]
  end
end
