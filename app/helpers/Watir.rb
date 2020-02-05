module Watir
  class Element
    def obscured?
      element_from_point_js = 'return document.elementFromPoint(arguments[0], arguments[1]);'
      element_at_point = execute_script(element_from_point_js, *center)
      ![self, elements.to_a].flatten.include?(element_at_point)
    end
  end
end
