# frozen_string_literal: true

class OffenderJurisdictionsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  def index; end

  def show
    # if this page has an "error" query param then don't attempt a search and
    # just show that error
    case params[:error]
    when 'error_no_results'
      @search_error = I18n.t('offender_search.error_no_results',
        search_sid: params[:error_sid])
    when 'error_connection_failed'
      @search_error = I18n.t('offender_search.error_connection_failed')
    when 'error_offender_expired'
      @search_error = I18n.t('offender_search.error_offender_expired')
    end
  end

  def search
    if offender_params[:sid].present?
      # when searching for a SID, just go to /offenders/<sid> and let that page
      # do the search
      redirect_to offender_path(:oregon, offender_params[:sid])
      return
    end

    error = valid_offender_search?(params[:jurisdiction].to_sym)
    if error
      @search_error = error
      return render :show
    end

    # otherwise, do the search!

    @results = []

    if %w[dcj unknown].include?(params[:jurisdiction])
      # DCJ search requires last_name and (SID|dob) for now :(
      @results.push(search_dcj)
    end

    if %w[oregon unknown].include?(params[:jurisdiction])
      @results.push(*search_oregon)
    end

    @results.compact!

    @grouped_results = OffenderGrouper.new(@results)
    @name_highlighter = OffenderNameHighlighter.new(offender_params)

    @mixpanel.track('search',
      jurisdiction: params[:jurisdiction],
      num_results: @grouped_results.total_results,
      fields: offender_params.to_unsafe_hash)

    if @results.empty?
      full_name = sanitize("#{offender_params[:first_name]} #{offender_params[:last_name]}")

      case params[:jurisdiction].to_sym
      when :oregon
        @search_error ||= I18n.t(
          'offender_search.error_no_results_prison_by_name_html',
          name: full_name,
        ).html_safe
      when :dcj
        @search_error ||= I18n.t(
          'offender_search.error_no_results_dcj_by_name_html',
          name: full_name,
        ).html_safe
      end
    end

    render :show
  end

  private

  def valid_offender_search?(jurisdiction)
    case jurisdiction
    when :oregon
      # one of first_name, or last_name must be present
      unless offender_params[:first_name].present? || offender_params[:last_name].present?
        I18n.t('offender_search.error_missing_name')
      end
    when :dcj
      # last name and DOB must all be present
      unless offender_params[:last_name].present?
        return I18n.t('offender_search.error_missing_last_name')
      end

      unless offender_params[:dob][:year].present? &&
          offender_params[:dob][:month].present? &&
          offender_params[:dob][:day].present?
        return I18n.t('offender_search.error_missing_dob')
      end
    when :unknown
      # last name and dob are all required
      unless offender_params[:last_name].present?
        return I18n.t('offender_search.error_missing_last_name')
      end

      unless offender_params[:dob][:year].present? &&
          offender_params[:dob][:month].present? &&
          offender_params[:dob][:day].present?
        return I18n.t('offender_search.error_missing_dob')
      end
    end
  end

  def offender_params
    params.fetch(:offender, {})
  end

  def search_dcj
    offender_dob = begin
                     Date.new(
                       offender_params[:dob][:year].to_i,
                       offender_params[:dob][:month].to_i,
                       offender_params[:dob][:day].to_i,
                     )
                   rescue
                     nil
                   end

    # sanity check the DOB that it is not too far in the past or in the future
    unless offender_dob && 120.years.ago < offender_dob && offender_dob < Date.today
      date_string =
        offender_params[:dob].values_at(:month, :day, :year).join('/')

      @search_error =
        I18n.t('offender_search.error_invalid_date', date: date_string)

      # Since DOB is required, may as well not do anything
      return
    end

    result = nil
    begin
      start_time = Time.now
      result = DcjClient.new.search_for_offender(
        dob: offender_dob,
        last_name: offender_params[:last_name],
      )
      @mixpanel.track('search-duration', duration: Time.now - start_time)
    rescue DcjClient::RequestError => ex
      Raven.capture_exception(ex)
      @search_error = I18n.t('offender_search.error_connection_failed')
    end

    result
  end

  def search_oregon
    # otherwise, time to search by name!
    results = []

    begin
      results = OffenderScraper.search_by_name(
        offender_params[:first_name],
        offender_params[:last_name],
      )
    rescue OosMechanizer::Searcher::ConnectionFailed
      @search_error = I18n.t('offender_search.error_connection_failed')
    rescue OosMechanizer::Searcher::TooManyResultsError
      @search_error = I18n.t('offender_search.error_too_many_results')
    end

    results
  end
end
