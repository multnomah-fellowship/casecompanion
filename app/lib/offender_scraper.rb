require 'oos_mechanizer'
require 'json'

module OffenderScraper
  # @return Array<Hash> Array of hashes with information from the search results
  #   table. This search is not cached because it's assumed that this is used on
  #   a search results page that can take a couple seconds to load.
  def self.search_by_name(first_name, last_name)
    searcher = OosMechanizer::Searcher.new
    searcher.each_result(first_name: first_name, last_name: last_name).to_a
  end

  # @return Hash? Information about the offender, if found. This method is
  #   cached for a day since it's kind of slow.
  def self.offender_details(sid)
    cached = OffenderSearchCache.find_by(offender_sid: sid)

    if cached
      cached.data.symbolize_keys
    else
      data = self.fetch_offender_details(sid)

      return nil if data.nil?

      OffenderSearchCache
        .unscoped
        .where(offender_sid: sid)
        .first_or_create
        .update_attributes(data: data)

      data
    end
  end

  private

  def self.fetch_offender_details(sid)
    searcher = OosMechanizer::Searcher.new
    searcher.offender_details(sid)
  end
end
