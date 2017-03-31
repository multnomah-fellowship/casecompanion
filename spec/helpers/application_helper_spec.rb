require 'rails_helper'

describe ApplicationHelper do
  describe '#name_reorderer' do
    it 'reorders names correctly' do
      expect(helper.name_reorderer('Calaway, Laurel')).to eq('Laurel Calaway')
    end
  end

  describe '#first_name' do
    it 'gives first names correctly' do
      expect(helper.first_name('Calaway, Laurel')).to eq('Laurel')
      expect(helper.first_name('Laurel Calaway')).to eq('Laurel')
    end
  end

  describe '#format_phone' do
    it 'formats a phone number as intended' do
      expect(helper.format_phone('+11234567890')).to eq('(123) 456-7890')
    end
  end

  describe '#link_path_for_offender_or_search' do
    context 'with a nil notification' do
      it 'links to the search page' do
        expect(helper.link_path_for_offender_or_search(nil)).to eq(helper.offenders_path)
      end
    end

    context 'with a notification with offender_sid unknown' do
      let(:notification) do
        Notification.new(
          first_name: 'Tom',
          offender_sid: Notification::UNKNOWN_SID,
          phone_number: '123-456-7890',
        )
      end

      it 'links to the search page' do
        expect(helper.link_path_for_offender_or_search(notification))
          .to eq(helper.offenders_path)
      end
    end

    context 'with a notification with an offender id' do
      let(:notification) do
        Notification.new(
          first_name: 'Tom',
          offender_sid: '1234',
          phone_number: '123-456-7890',
        )
      end

      it 'links to that offender' do
        expect(helper.link_path_for_offender_or_search(notification))
          .to eq(helper.offender_path(notification.offender_sid))
      end
    end
  end
end
