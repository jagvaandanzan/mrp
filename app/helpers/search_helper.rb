module SearchHelper
  def get_search_criteria(*args)
    search_fields = args.reject {|value, label| value.blank?}.map {|value, label| "#{label}: #{value}"}
    if search_fields.size > 0
      content_tag :div, class: 'box-header' do
        content_tag :i, class: 'fa fa fa-search' do
          content_tag :h3, class: 'box-title p-l-10', style: 'font-size: 14px' do
            "#{t('controls.button.search')} (#{search_fields.join('・')})"
          end
        end
      end
    end
  end

  def get_category_parents(obj)
    headers = []
    if obj.presence
      get_recursive_header(obj, headers)
    end

    headers
  end
end

def get_recursive_header(obj, headers)
  headers.push(obj)
  if obj.parent.presence
    get_recursive_header(obj.parent, headers)
  else
    headers
  end
end

def get_search_recursive(obj, type)

  header_li = content_tag :li do # first header
    link_to(type == "category" ? "Ангилалууд" : "Байршлууд",
            type == "category" ? users_product_categories_path(parent_id: nil) : users_product_locations_path(parent_id: nil))
  end

  main_ol = content_tag :ol, class: 'breadcrumb' do
    concat header_li

    if obj.presence
      headers = get_recursive_header(obj, [])

      headers.reverse().each do |item|
        unless item.nil?
          li = content_tag :li, class: item == headers.first ? "active" : "" do
            link_to(item.name, type == "category" ? users_product_categories_path(parent_id: item.id)
                                   : users_product_locations_path(parent_id: item.id))
          end
          concat li
        end # item is null check
      end # headers loop end
    end # obj presence check
  end # ol .breadcrumb

  content_tag :div, class: 'row breadcrumb-container' do
    content_tag :div, class: 'col-xs-12 col-sm-12 col-md-12' do
      content_tag :div, class: 'box box-solid' do
        concat main_ol
      end #div .box box-solid
    end #div .col-xs-12
  end #div .row breadcrumb-container
end

def get_text_recursive(obj)
  name = ""
  if obj.presence
    headers = get_recursive_header(obj, [])
    headers.reverse.each do |item|
      unless item.nil?
        name += "#{item.name}#{item == headers.first ? "" : " >> "}"
      end
    end
  end
  name
end

def get_name_recursive(obj)
  content_tag :span, class: '' do
    if obj.presence
      headers = get_recursive_header(obj, [])

      headers.reverse.each do |item|
        unless item.nil?
          i = content_tag :i do
            # concat link_to(item.name, users_product_categories_path(parent_id: item.id))
            concat item.name
            concat item == headers.first ? "" : " >> "
          end
          concat i
        end # item is null check
      end # headers loop end
    end # obj presence check
  end # main div end
end

