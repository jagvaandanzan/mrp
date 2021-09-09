class AbilityLogistic
  include CanCan::Ability

  def initialize(logistic)
    # load_and_authorize_resource модел бол
    # authorize_resource class: false модел биш бол

    logistic.logistic_permission_rels.each do |rel|
      role = rel.role.to_s[3..rel.role.to_s.length].to_sym

      case rel.logistic_permission.name
      when "supply_orders"
        can role, :supply_order
      when "shipping_er"
        can role, ShippingEr
      when "shipping_ub"
        can role, ShippingUb
      else
        puts "it was something else"
      end
    end
  end
end
