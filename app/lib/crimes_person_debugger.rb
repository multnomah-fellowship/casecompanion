# frozen_string_literal: true

# rubocop:disable Lint/LineLength

require 'tiny_tds'

# This is very much a WIP; it hasn't been useful for me yet but I'm going to
# commit it anyway.
class CrimesPersonDebugger
  def initialize(email:, url: ENV['CRIMES_DATABASE_URL'])
    resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new({})
    config = resolver.resolve(url)

    config['timeout'] ||= 900 # seconds

    @client = TinyTds::Client.new(**config.symbolize_keys)
    @email = email
  end

  def print_summary(to: $stdout)
    to.puts "Looking up Email: #{@email}"

    to.puts "  -> found #{case_person_address.length} address record(s)"
    case_person_address.each do |a|
      to.puts "     PERSON ID: #{a['PERSON_ID_NBR']} / ALL DOCS: #{a['ALL_DOCS']} " \
        "/ SUB ONLY: #{a['SUB_ONLY']}"
    end

    to.puts 'Looking up cases based off the first address record...'
    to.puts "  -> found #{cases.length} cases"
    cases.each do |c|
      to.puts "     ID: #{c['CASE_NBR']} / CREATE: #{c['CREATE_DATE']}"
      people = case_people(c['CASE_ID_NBR'])
      people.each do |p|
        to.puts "       PERSON (#{p['CASE_PERSON_TYPE']}): #{p['FIRST_NAME']} #{p['LAST_NAME']}"
        if p['CASE_PERSON_TYPE'] == 'DEFENDANT'
          to.puts "         COURT_NBR: #{p['COURT_NBR']} / DOB: #{p['DOB'].to_date} / SID: #{p['OREGON_SID_NBR']}"
        end
      end
    end

    to.puts 'Looking up probation sentences for the cases...'
    to.puts "  -> found #{probation_sentences.length} sentences"
    probation_sentences.each do |s|
      to.puts "     CASE: #{s['CASE_NBR']} / ID: #{s['PROBATION_ID_NBR']} / TYPE: #{code_to_text(s['PROBATION_TYPE'])} / TOTAL_PROB_QTY: " \
        "#{s['TOTAL_PROB_QTY']} #{s['TOTAL_PROB_QTY_UNIT']} / CREATE: #{s['CREATE_DATE']}"
    end

    nil
  end

  def case_person_address
    @_address ||=
      @client
        .execute("SELECT * FROM CASE_PERSON_ADDRESS WHERE EMAIL = '#{@email}'")
        .to_a
  end

  def case_people(case_id_nbr)
    @_case_people ||= {}
    @_case_people[case_id_nbr] ||= @client.execute(<<-SQL).to_a
      SELECT CASE_PERSON.COURT_NBR, CASE_PERSON.CASE_PERSON_TYPE, CASE_PERSON_INFO.* FROM CASE_PERSON
      INNER JOIN CASE_PERSON_INFO
        ON CASE_PERSON_INFO.PERSON_ID_NBR = CASE_PERSON.PERSON_ID_NBR
      WHERE CASE_ID_NBR = '#{case_id_nbr}'
    SQL
  end

  def case_person
    person_id_nbr = case_person_address[0]['PERSON_ID_NBR']

    @_person ||=
      @client
        .execute("SELECT * FROM CASE_PERSON WHERE PERSON_ID_NBR = '#{person_id_nbr}'")
        .to_a
  end

  def cases
    case_id_nbrs = case_person.map { |p| p['CASE_ID_NBR'].to_i }.join(',')

    @_cases ||=
      @client
        .execute("SELECT * FROM CASE_MAIN WHERE CASE_ID_NBR IN (#{case_id_nbrs})")
        .to_a
  end

  # ~ 40 seconds
  def probation_sentences
    @_probation_sentences ||=
      @client
        .execute(<<-SQL).to_a
          SELECT     PROBATION.*, CASE_MAIN.CASE_NBR
          FROM         PROBATION INNER JOIN
                                CHARGE_SENTENCE ON PROBATION.SENTENCE_ID_NBR = CHARGE_SENTENCE.SENTENCE_ID_NBR INNER JOIN
                                CASE_CHARGE ON CHARGE_SENTENCE.CHARGE_ID_NBR = CASE_CHARGE.CHARGE_ID_NBR INNER JOIN
                                CASE_MAIN ON CASE_CHARGE.CASE_ID_NBR = CASE_MAIN.CASE_ID_NBR INNER JOIN
                                CASE_PERSON ON CASE_MAIN.CASE_ID_NBR = CASE_PERSON.CASE_ID_NBR INNER JOIN
                                CASE_PERSON_ADDRESS ON CASE_PERSON.PERSON_ID_NBR = CASE_PERSON_ADDRESS.PERSON_ID_NBR
          WHERE     (CASE_PERSON_ADDRESS.EMAIL = '#{@email}')
        SQL
  end

  def code_to_text(code)
    @_codes ||= {}

    @_codes.fetch(code) do
      @client.execute(<<-SQL).to_a[0]['TABLE_DESC']
        SELECT * FROM CODE_TABLE WHERE TABLE_CODE = '#{code}'
      SQL
    end
  end
end
