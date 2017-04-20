require 'rails_helper'

RESULTS = [
  { sid: '16077966', first: 'AARON', middle: '', last: 'BROWN', dob: '09/1986' },
  { sid: '16077966', first: 'AARON', middle: 'M', last: 'BROWN', dob: '09/1986' },
  { sid: '16077966', first: 'AARON', middle: 'MICHAEL', last: 'BROWN', dob: '09/1986' },
  { sid: '16077966', first: 'AARON', middle: 'MICHAEL', last: 'BROWN', dob: '09/1986' },
  { sid: '16077966', first: 'AARON', middle: 'MICHAEL', last: 'BROWN-ANDRESON', dob: '09/1986' },
  { sid: '16077966', first: 'AARON', middle: 'MICAHEL', last: 'BROWN', dob: '09/1986' },
  { sid: '16077966', first: 'AARON', middle: 'MICHEAL', last: 'BROWN', dob: '09/1986' },
  { sid: '16077966', first: 'AARON', middle: 'MICHAEL', last: 'BROWN', dob: '09/1986' },
  { sid: '19046875', first: 'AARON', middle: '', last: 'BROWN', dob: '04/1991' },
  { sid: '19046875', first: 'AARON', middle: 'ARTHUR', last: 'BROWN', dob: '04/1991' },
  { sid: '19046875', first: 'AARON', middle: 'A', last: 'BROWN', dob: '04/1991' },
  { sid: '19046875', first: 'AARON', middle: '', last: 'BROWN', dob: '04/1991' },
  { sid: '19046875', first: 'AARON', middle: 'KARMA', last: 'BROWN', dob: '04/1991' },
]

describe OffenderGrouper do
  subject { described_class.new(RESULTS) }

  describe '#each_group' do
    it 'returns an enumerable of groups' do
      expect(subject.each_group).to be_a(Enumerable)
    end

    it 'returns the right number of groups' do
      expect(subject.each_group.to_a.length).to eq(2)
    end

    it 'each group has a SID, full name, DOB, and aliases' do
      expect(subject.each_group.to_a).to all(include(:sid, :full_name, :dob, :aliases))
    end

    it 'returns the right data' do
      expect(subject.each_group.first).to include(sid: RESULTS[0][:sid])
      expect(subject.each_group.first).to include(full_name: 'Aaron Brown')
      expect(subject.each_group.first).to include(dob: '09/1986')
      expect(subject.each_group.first).to include(aliases: [
        'Aaron M Brown',
        'Aaron Michael Brown',
        'Aaron Michael Brown',
        'Aaron Michael Brown-andreson',
        'Aaron Micahel Brown',
        'Aaron Micheal Brown',
        'Aaron Michael Brown',
      ])
    end
  end

  describe '#total_results' do
    it 'equals the number of distinct SIDs' do
      expect(subject.total_results).to eq(2)
    end
  end
end
