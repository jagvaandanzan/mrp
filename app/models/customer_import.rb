class CustomerImport
  include ActiveModel::Model
  require 'roo'

  attr_accessor :file, :customer_id, :warehouse_id
  # :warehouse_id,
  validates :customer_id, :file, presence: true

  def initialize(attributes = {})
    attributes.each {|barcode, value| send("#{barcode}=", value)}
  end

  def persisted?
    false
  end

  def load_imported_items
    spreadsheet = Roo::Spreadsheet.open(file.path) # open spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      item = CustomerItem.new
      item.attributes = row.to_hash
      item
    end

  end

  def imported_items
    @imported_items ||= load_imported_items
  end

  def valid
    if imported_items.map(&:valid?).all?
      true
    else
      imported_items.each_with_index do |item, index|
        self.errors.add :file, "-row #{index + 1}: #{item.errors.full_messages}" unless item.valid?
      end
      false
    end
  end

  def save
    if imported_items.map(&:valid?).all?
      count = 0
      imported_items.each do |exl|
        items = ProductFeatureItem.join_products
                    .by_customer(customer_id)
                    .by_barcode(exl.barcode)
        if items.present?
          count += 1
          item = items.first
          item.balance = exl.quantity
          item.customer_warehouse_id = warehouse_id

          item.save
        end
      end
      count
    else
      imported_items.each_with_index do |item, index|
        self.errors.add :file, "-row #{index + 2}: #{item.errors.full_messages}" unless item.valid?
      end
      0
    end
  end

end

class CustomerItem
  include ActiveModel::Model

  attr_accessor :barcode, :quantity

  validates :barcode, :quantity, presence: true
  validates :quantity, numericality: {greater_than: 0, only_integer: true, message: :invalid}


end