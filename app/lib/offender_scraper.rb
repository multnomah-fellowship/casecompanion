# frozen_string_literal: true

require 'oos_mechanizer'
require 'json'

module OffenderScraper
  # @return Array<Hash> Array of hashes with information from the search results
  #   table. This search is not cached because it's assumed that this is used on
  #   a search results page that can take a couple seconds to load.
  def self.search_by_name(first_name, last_name)
    search_params = {}
    search_params[:first_name] = first_name if first_name.present?
    search_params[:last_name] = last_name if last_name.present?

    searcher = OosMechanizer::Searcher.new
    searcher.each_result(**search_params).map do |result|
      result.merge(jurisdiction: :oregon)
    end
  end

  # @return Hash? Information about the offender, if found. This method is
  #   cached for a day since it's kind of slow.
  def self.offender_details(sid)
    cached = OffenderSearchCache.find_by(offender_sid: sid)

    if cached.try(:data)
      cached.data.symbolize_keys.merge(
        jurisdiction: :oregon,
      )
    else
      data = fetch_offender_details(sid)

      return nil if data.nil?

      data[:jurisdiction] = :oregon

      OffenderSearchCache
        .unscoped
        .where(offender_sid: sid)
        .first_or_create
        .update_attributes(data: data)

      data
    end
  end

  # private
  def self.fetch_offender_details(sid)
    searcher = OosMechanizer::Searcher.new
    searcher.offender_details(sid)
  end
end
