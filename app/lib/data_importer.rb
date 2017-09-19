# frozen_string_literal: true

module DataImporter
  module Connections
    class Crimes < ActiveRecord::Base
      establish_connection(ENV['CRIMES_DATABASE_URL'])
    end
  end
end
