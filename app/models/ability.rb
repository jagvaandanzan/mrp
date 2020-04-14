class Ability
  include CanCan::Ability

  def initialize(user)
    # load_and_authorize_resource модел бол
    # authorize_resource class: false модел биш бол
    user.user_permission_rels.each do |rel|
      role = rel.role.to_s[3..rel.role.to_s.length].to_sym

      case rel.user_permission.name
      when "product_suppy_order"
        can role, ProductSupplyOrder
      when "product_income"
        can role, ProductIncome
      when "product"
        can role, Product
        can role, ProductCategory
        can role, ProductFeatureOption
        can role, ProductFeature
        can role, CategoryFilterGroup
      when "operator"
        can role, FbComment
        can role, Operator
        can role, Salesman
      when "map_location"
        can role, LocDistrict
        can role, LocKhoroo
        can role, Location
      when "product_supplier"
        can role, ProductSupplier
      when "product_location"
        can role, ProductLocation
      else
        puts "it was something else"
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
