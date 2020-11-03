class AbilityOperator
  include CanCan::Ability

  def initialize(operator)
    # load_and_authorize_resource модел бол
    # authorize_resource class: false модел биш бол
    operator.operator_permission_rels.each do |rel|
      role = rel.role.to_s[3..rel.role.to_s.length].to_sym

      case rel.operator_permission.name
      when "fb_comment"
        can role, FbComment
        can role, FbCommentArchive
      when "fb_comment_action"
        can :read, FbCommentAction
      when "bank_transactions"
        can :read, BankTransaction
      when "sms_message"
        can role, SmsMessage
      when "map_location"
        can role, LocDistrict
        can role, LocKhoroo
        can role, Location
      else
        puts "it was something else"
      end
    end
  end
end
