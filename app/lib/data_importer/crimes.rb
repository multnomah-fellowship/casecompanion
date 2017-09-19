# frozen_string_literal: true

module DataImporter
  # All the models and query logic for CRIMES queries.
  class Crimes
    module Models
      class Case < DataImporter::Connections::Crimes
        self.primary_key = 'CASE_ID_NBR'
        self.table_name = 'CASE_MAIN'
      end
    end

    def self.case_list
      Models::Case.first(5)
    end
  end
end
