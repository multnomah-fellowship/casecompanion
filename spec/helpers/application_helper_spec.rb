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

  describe '#simpler_format' do
    it 'converts properly' do
      expect(helper.simpler_format("foo\n\nbar")).to eq("<p>foo</p><p>bar</p>")
      expect(helper.simpler_format("foo\nbar\n\nbaz")).to eq("<p>foo\nbar</p><p>baz</p>")
    end

    it 'returns an html safe string' do
      expect(helper.simpler_format("foo\n\nbar")).to be_html_safe
    end
  end

  describe '#mixpanel_track_message' do
    let(:first_line) { 'There was a problem with your thing.' }
    let(:message) { <<-MESSAGE.strip_heredoc }
      #{first_line}

      Bad stuff is happening now.
    MESSAGE

    # this is a weird test because it's so coupled to the implementation...
    it 'tracks an event properly' do
      event_data = { level: :error, message: message, first_line: first_line }

      expect(helper.mixpanel_track_message(:error, message))
        .to eq(<<-HTML.strip_heredoc.strip)
          <script>mixpanel.track('message-seen', #{JSON.generate(event_data)});
          </script>
      HTML
    end
  end
end
