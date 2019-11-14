puts '[START] load master data.'
# load(Rails.root.join('db', 'seeds', 'master.rb'))
puts '[END] load master data.'

########################################################
puts '[START] load test data.'
load(Rails.root.join('db', 'seeds', "#{Rails.env.downcase}.rb"))
puts '[END] load test data.'
