# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminPermission.destroy_all
AdminPermission.create!([{:id => 1, :name => 'Админ', :description => 'Админ'}])
AdminUser.create!(:email => 'enkhamgalan.ch@icloud.com', :admin_permission_id => 1, :password => 'pass1234', :password_confirmation => 'pass1234') if Rails.env.development?

UserPosition.destroy_all
UserPosition.create!([{:name => 'Менежер'}, {:name => 'Нярав'}, {:name => 'Оператор'}])
UserPermission.destroy_all
UserPermission.create!([{:id => 1, :name => 'Админ', :description => 'Админ'}])
