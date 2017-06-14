require 'rails_helper'

describe OffenderNameHighlighter do
  let(:search_params) { { first_name: 'Aaron', last_name: 'Brown' } }

  subject { described_class.new(search_params) }

  describe '#highlight' do
    it 'returns an HTML safe string' do
      expect(subject.highlight('Aaron Brown')).to be_html_safe
    end

    it 'highlights a name correctly' do
      expect(subject.highlight('Aaron Brown'))
        .to eq('<strong>Aaron</strong> <strong>Brown</strong>')
    end

    it 'highlights a complex name correctly' do
      expect(subject.highlight('Aaron Brown-Browning-Brownson'))
        .to eq('<strong>Aaron</strong> <strong>Brown</strong>-Browning-Brownson')
    end

    it 'highlights a UPCASED NAME correctly' do
      expect(subject.highlight('AARON BROWN'))
        .to eq('<strong>AARON</strong> <strong>BROWN</strong>')
    end

    it 'sanitizes the input' do
      expect(subject.highlight('<script>somebody</script>'))
        .not_to include('script')
    end

    context 'when not all HIGHLIGHT_FIELD_NAMES are given' do
      let(:search_params) { { last_name: 'Aaron' } }

      it 'still highlights the fields' do
        expect(subject.highlight('Aaron Brown')).to eq('<strong>Aaron</strong> Brown')
      end
    end

    describe 'with blank search terms' do
      let(:search_params) { { first_name: '', last_name: 'Aaron', sid: '' } }

      it 'still highlights present fields' do
        expect(subject.highlight('John Aaron'))
          .to eq('John <strong>Aaron</strong>')
      end
    end
  end
end
