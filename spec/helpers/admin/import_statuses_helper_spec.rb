require 'rails_helper'

RSpec.describe Admin::ImportStatusesHelper do
  describe '#format_log_time' do
    it 'converts time properly' do
      database_time = '2018-05-27 04:36:38'
      formatted = helper.format_log_time(database_time)

      expect(formatted).to eq('Saturday May 26, 2018 at 9:36 pm')
    end
  end
end
