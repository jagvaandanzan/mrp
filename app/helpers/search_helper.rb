module SearchHelper
  def get_search_criteria(*args)
    search_fields = args.reject { |value, label| value.blank? }.map { |value, label| "#{label}: #{value}" }
    if search_fields.size > 0
      content_tag :div, class: 'box-header' do
        content_tag :i, class: 'fa fa fa-search' do
          content_tag :h3, class: 'box-title p-l-10', style:'font-size: 14px' do
            "#{t('controls.button.search')} (#{search_fields.join('・')})"
          end
        end
      end
    end
  end
end
def get_index(index)
  (index + 1).to_s + ". "
end