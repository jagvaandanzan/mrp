class AbilityUser
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
      when "product_income_log"
        can role, ProductIncomeLog
      when "product"
        can role, Product
        can role, ProductDiscount
        can role, ProductCategory
        can role, ProductFeatureOption
        can role, ProductFeatureGroup
        can role, ProductFeature
        can role, ProductFeatureItem
        can role, CategoryFilterGroup
        can role, Brand
        can role, TechnicalSpecification
        can role, SizeInstruction
        can role, Manufacturer
      when "operator"
        can role, Operator
        can role, Salesman
        can role, :delivery_report
      when "product_supplier"
        can role, Customer
      when "product_location"
        can role, ProductLocation
      when "fb_post"
        can role, FbPost
      when "fb_comment"
        can :read, FbComment
        can role, FbCommentArchive
      when "bank_transactions"
        can role, BankTransaction
        can role, BankAccount
        can role, BankDealingAccount
        can role, SaleTax
      when "sms_message"
        can role, SmsMessage
      else
        puts "it was something else"
      end
    end
  end
end
