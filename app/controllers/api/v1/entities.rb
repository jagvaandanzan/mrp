module API
  module V1
    module Entities

      class SysUser < Grape::Entity
        expose :name, :email, :updated_at
      end

    end
  end
end
