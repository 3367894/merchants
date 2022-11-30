require 'csv'

path = Rails.root.join("db", "seeds_data")

%w[merchant shopper order].each do |entity_name|
  klass = entity_name.classify.constantize

  CSV.read(path.join("#{entity_name.pluralize}.csv"), headers: true).each do |data|
    entity = klass.find_by(id: data["id"])
    klass.create!(data) unless entity
  end
end
