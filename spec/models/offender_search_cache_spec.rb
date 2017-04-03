require 'rails_helper'

describe OffenderSearchCache do
  describe '.purge_all!' do
    context 'with an empty set of records' do
      it 'does nothing without error' do
        expect do
          OffenderSearchCache.where(offender_sid: 'A_FAKE_SID').purge_all!
        end.not_to raise_error
      end
    end

    context 'with a previously-valid record' do
      it 'purges the record so it is no longer returned' do
        sid = (Random.rand * 1_000_000).floor

        OffenderSearchCache.create(offender_sid: sid, data: [])
        expect(OffenderSearchCache.find_by(offender_sid: sid)).to be_present

        OffenderSearchCache.where(offender_sid: sid).purge_all!
        expect(OffenderSearchCache.find_by(offender_sid: sid)).not_to be_present
      end
    end
  end
end
