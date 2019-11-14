# frozen_string_literal: true

class SysUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable :registerable, :recoverable, :rememberable,
  devise :database_authenticatable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
end
