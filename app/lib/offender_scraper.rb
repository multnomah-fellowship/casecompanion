require 'mechanize'
require 'json'

class OffenderScraper
  def self.offender_details(sid)
    cached = OffenderSearchCache.find_by(offender_sid: sid)

    if cached
      cached.data.symbolize_keys
    else
      self.scrape!(sid).tap do |data|
        return nil if data.nil?

        OffenderSearchCache
          .unscoped
          .where(offender_sid: sid)
          .first_or_create
          .update_attributes(data: data)
      end
    end
  end

  private

  def self.scrape!(sid)
    scraper = Mechanize.new
    scraper.get('http://docpub.state.or.us/OOS/intro.jsf') do |page|
      search_page = scraper.click 'I Agree'
      results_page = search_page.form_with(id: 'mainBodyForm') do |f|
        f['mainBodyForm:SidNumber'] = sid
      end.click_button

      offenses = results_page.css('[id="offensesForm:offensesTable"] tbody tr:nth-child(2n+1)')

      return nil if results_page.css('#errorMessages').text =~ /invalid characters detected/i
      return nil if results_page.css('#errorMessages').text =~ /no matching records/i

      return {
        sid: results_page.css('[id="offensesForm:out_SID"]').text,
        name: results_page.css('[id="offensesForm:name"]').text,

        age: results_page.css('[id="offensesForm:age"]').text,
        gender: results_page.css('[id="offensesForm:sex"]').text,
        height: results_page.css('[id="offensesForm:height"]').text,
        weight: results_page.css('[id="offensesForm:weight"]').text,
        dob: results_page.css('[id="offensesForm:dob"]').text,
        race: results_page.css('[id="offensesForm:race"]').text,
        hair: results_page.css('[id="offensesForm:hair"]').text,
        eyes: results_page.css('[id="offensesForm:eyes"]').text,

        caseload_number: results_page.css('[id="offensesForm:caseloadNumber"]').text,
        caseload_name: results_page.css('[id="offensesForm:caseloadMgrsTable"]').text.strip,

        location: results_page.css('[id="offensesForm:locationBlock"] a').text,
        status: results_page.css('[id="offensesForm:status"]').text,
        admission_date: results_page.css('[id="offensesForm:admitDate"]').text,
        earliest_release_date: results_page.css('[id="offensesForm:relDate"]').text,

        offenses: offenses.map {|o| o.text.strip.gsub(/\s+/, ',') },
        num_offenses: offenses.length,
      }
    end
  end
end
