# frozen_string_literal: true

module DataImporter
  # All the models and query logic for CRIMES queries.
  class Crimes
    def self.case_list
      DataImporter::Connections::Crimes.execute(<<-SQL).to_a
        SELECT * FROM "CASE_MAIN"
      SQL
    end
  end
end
