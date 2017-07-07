class MyAdvocateFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper

  def label(field, text, options = {})
    if @object.try(:errors).is_a?(ActiveModel::Errors) && @object.errors.include?(field)
      options['data-error'] = @object.errors.full_messages_for(field).first
      options['class'] ||= ''
      options['class'] = (options['class'].split(/\s+/) | ['active']).join(' ')
    end

    super(field, text, options)
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
end
