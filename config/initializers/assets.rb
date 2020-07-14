# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w( admin_users/administrators.js admin_users/common.js)
Rails.application.config.assets.precompile += %w( search.scss form.scss show.scss list.scss)
Rails.application.config.assets.precompile += %w( admin-lte/bower_components/raphael/raphael.min.js admin-lte/bower_components/morris.js/morris.min.js admin-lte/bower_components/morris.js/morris.css)
Rails.application.config.assets.precompile += %w( summernote/dist/summernote-bs4.css summernote/dist/summernote-bs4.js summernote_upload.js summernote/dist/lang/summernote-mn-MN.min.js)
Rails.application.config.assets.precompile += %w( admin-lte/bower_components/bootstrap-colorpicker/dist/css/bootstrap-colorpicker.min.css admin-lte/bower_components/bootstrap-colorpicker/dist/js/bootstrap-colorpicker.min.js)

