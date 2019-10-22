module FormHelper
  def field_errors(obj, field)
    if obj.errors[field].present?
      content_tag :small, class: 'text-danger' do
        content_tag :div do
          obj.errors.full_messages_for(field).join('<br/>').html_safe
        end
      end
    end
  end

  def get_user_field_errors(obj, field)
    if obj.errors[field].present?
      errors = obj.errors.details[field].map do |detail|
        if field == :email && detail[:error] == :taken
          message = " " + I18n.t('activerecord.errors.models.user.attributes.email.taken')
          "#{obj.errors.full_message(:email, message)}"
        else
          message = " " + I18n.t("activerecord.errors.models.user.attributes.email.#{detail[:error]}")
          obj.errors.full_message(:email, message)
        end
      end.uniq

      content_tag :small, class: 'text-danger' do
        errors.join('<br/>').html_safe
      end
    end
  end

  def get_error_class(obj, field)
    obj.try(:errors) && obj.errors.key?(field) ? 'has-error' : ''
  end

  def form_header(header, classes: [])
    classes.push('content-header') unless classes.include?('content-header')
    content_tag :section, class: classes do
      content_tag :h1, header
    end
  end

  def form_body
    content_tag :div, class: 'box-body' do
      yield
    end
  end

  def show_body(&block)
    content_tag :section, class: 'content container-fluid' do
      content_tag :div, class: 'row' do
        content_tag :div, class: 'col-xs-12 col-md-12 col-lg-12' do
          yield
        end
      end
    end
  end

  def form_group_email(model, name)

    body_content = content_tag :div, class: 'col-sm-9' do
      email_field_tag(name, '', id: model + '_' + name.to_s, class: 'form-control')
    end

    content_tag :div, class: 'form-group' do
      safe_concat(label_tag(model + '_' + name.to_s, name, class: 'col-sm-3 control-label'))
      safe_concat(body_content)
    end
  end

  def nested_add_btn
    content_tag :button, type: 'button', class: 'btn btn-block btn-success btn-xs', id: 'btn-append' do
      content_tag :i, class: 'fa fa-plus', style: 'color: white' do
      end
    end
  end

  def nested_remove_btn
    content_tag :i, class: 'fa fa-fw fa-minus-circle' do
    end
  end

end
