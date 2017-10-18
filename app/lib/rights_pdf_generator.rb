# frozen_string_literal: true

require 'prawn'

class RightsPdfGenerator
  attr_reader :data

  TIME_ZONE = 'America/Los_Angeles'
  LINE_HEIGHT = 20

  def initialize(subscription)
    @subscription = subscription
    @data = nil
  end

  # rubocop:disable Metrics/AbcSize
  def generate
    pdf = Prawn::Document.new
    pdf.font 'Times-Roman'

    pdf.bounding_box [300, pdf.cursor], width: 200 do
      pdf.text "Date: #{created_at_date}"
      pdf.move_down LINE_HEIGHT - pdf.font_size

      pdf.text "DA#: #{@subscription.case_number}"
    end

    pdf.move_down 50

    pdf.text "Victim's Rights Notification", style: :bold
    pdf.move_down LINE_HEIGHT - pdf.font_size
    pdf.text <<-INTRO.strip_heredoc.tr("\n", ' ')
      This VRN was generated on behalf of #{@subscription.first_name}
      #{@subscription.last_name} by CaseCompanion.org.
    INTRO

    pdf.move_down LINE_HEIGHT - pdf.font_size

    pdf.move_down LINE_HEIGHT

    box_width = pdf.font_size
    box_margin = pdf.font_size

    # Draw the rights checkboxes along with the labels
    @subscription.rights_hash.each do |right, is_checked|
      pdf.rectangle [0, pdf.cursor], box_width, box_width
      pdf.draw_text 'x', at: [3, pdf.cursor - box_width / 2 - 3], style: :bold if is_checked
      pdf.stroke
      pdf.bounding_box [box_width + box_margin, pdf.cursor], width: 500 do
        pdf.text right
      end
      pdf.move_down LINE_HEIGHT / 2
    end

    pdf.move_down LINE_HEIGHT

    # "Signature" field and label
    pdf.bounding_box [0, pdf.cursor], width: 200 do
      pdf.text "/s/ #{@subscription.first_name} #{@subscription.last_name}"
      pdf.line [0, pdf.cursor], [200, pdf.cursor]
      pdf.stroke
      pdf.move_down 2
      pdf.text 'Signature', size: 8
      pdf.move_up pdf.bounds.height
    end

    # "Date" field and label
    pdf.bounding_box [220, pdf.cursor], width: 200 do
      pdf.text created_at_date
      pdf.line [0, pdf.cursor], [200, pdf.cursor]
      pdf.stroke
      pdf.move_down 2
      pdf.text 'Date', size: 8
    end

    pdf.move_down LINE_HEIGHT

    # "Email" field and label
    pdf.bounding_box [0, pdf.cursor], width: 200 do
      pdf.text @subscription.email
      pdf.line [0, pdf.cursor], [200, pdf.cursor]
      pdf.stroke
      pdf.move_down 2
      pdf.text 'Email', size: 8
      pdf.move_up pdf.bounds.height
    end

    # "Phone Number" field and label
    pdf.bounding_box [220, pdf.cursor], width: 200 do
      pdf.text @subscription.phone_number
      pdf.line [0, pdf.cursor], [200, pdf.cursor]
      pdf.stroke
      pdf.move_down 2
      pdf.text 'Phone Number', size: 8
      pdf.move_up pdf.bounds.height
    end

    @data = pdf.render

    self
  end

  def filename
    %W[
      VRN
      #{@subscription.case_number}
      #{@subscription.first_name}
      #{@subscription.last_name}
    ].join('-') + '.pdf'
  end

  private

  def created_at_date
    @subscription.created_at.in_time_zone(TIME_ZONE).to_date.strftime('%m/%d/%Y')
  end
end
