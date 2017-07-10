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

    it 'formats a phone number with an extension' do
      expect(helper.format_phone('503-555-1234 ext 88449')).to eq('(503) 555-1234 ext 88449')
    end

    it 'removes a US country code' do
      expect(helper.format_phone('13305551234')).to eq('(330) 555-1234')
    end

    it 'removes whitespace between groups of numbers' do
      expect(helper.format_phone('330   555 1234 ext 123')).to eq('(330) 555-1234 ext 123')
    end

    it 'handles country code plus extension' do
      expect(helper.format_phone('1 330 555 1234 ex 1')).to eq('(330) 555-1234 ex 1')
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

  describe '#short_counselor_title' do
    it 'returns the right value for an existing prison' do
      expect(helper.short_counselor_title('Oregon State Penitentiary'))
        .to eq('Counselor, OSP')
    end

    it 'does not include an acronym when the prison is unknown' do
      expect(helper.short_counselor_title('Some Unknown Prison'))
        .to eq('Counselor')
    end
  end

  # this tests the nested-layout flow.
  describe '#render_component with a dropdown' do
    let(:body) { proc { "body here" } }
    let(:title) { 'Title here' }

    subject { helper.render_component('dropdown', title: title, &body) }

    it 'returns an <a> linking to a corresponding <div>' do
      doc = Nokogiri::HTML(subject)
      expand_id = doc.css('body > a').attr('href').value.gsub('#', '')
      expect(doc.css("body > div#expand-#{expand_id}")).to be_present
    end

    it 'passes the title and body to the component' do
      expect(subject).to include(title)
      expect(subject).to include(body.call)
    end
  end

  # this tests the partial based flow - the non-nested layout flow.
  describe '#render_component with an avatar_list_item' do
    let(:options) { { image: 'foo.jpg', name: 'Foo', caption: 'Bar bar baz' } }

    subject { helper.render_component('avatar_list_item', options) }

    it 'renders a component with the name and caption' do
      expect(subject).to include(options[:name])
      expect(subject).to include(options[:caption])
    end
  end
end
