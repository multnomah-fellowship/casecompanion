class MyAdvocateFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper

  def check_box(method, options = {}, checked_value = '1', unchecked_value = '0')
    add_class!(options, 'filled-in')

    super(method, options, checked_value, unchecked_value)
  end

  def radio_button(method, tag_value, options = {})
    add_class!(options, 'with-gap')

    super(method, tag_value, options)
  end

  def label(method, text = nil, options = {}, &block)
    if @object.try(:errors).is_a?(ActiveModel::Errors) && @object.errors.include?(method)
      options['data-error'] = @object.errors.full_messages_for(method).first
      add_class!(options, 'active')
    end

    super(method, text, options, &block)
  end

  def hidden_attribution_fields
    fields_for(:utm_attribution) do |f|
      [
        f.hidden_field(:utm_campaign),
        f.hidden_field(:utm_content),
        f.hidden_field(:utm_medium),
        f.hidden_field(:utm_source),
      ].join.html_safe
    end
  end

  def dob_select_field(method)
    fields_for(method) do |f|
      <<-HTML.html_safe
        <div class='row'>
          <div class='col s10 offset-s1'>
            #{f.label(:month, 'Date of Birth')}
          </div>
          <div class='col s3 offset-s1 m1 offset-m1'>
            <div class='input-field app-input-field--no-label'>
              #{f.text_field(:month, placeholder: 'MM')}
            </div>
          </div>
          <div class='col s3 m1'>
            <div class='input-field app-input-field--no-label'>
              #{f.text_field(:day, placeholder: 'DD')}
            </div>
          </div>
          <div class='col s4 m2'>
            <div class='input-field app-input-field--no-label'>
              #{f.text_field(:year, placeholder: 'YYYY')}
            </div>
          </div>
        </div>
      HTML
    end
  end

  def check_box_with_label(method, label_text)
    <<-HTML.html_safe
      #{check_box(method)} #{label(method, label_text, class: 'app-checkbox-with-label')}
    HTML
  end

  private

  def add_class!(options, *new_classes)
    options['class'] ||= ''
    options['class'] = (options['class'].split(/\s+/) | new_classes).join(' ')
  end
end
