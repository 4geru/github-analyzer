class CsvBuilder
  def initialize(file_title)
    @file_title = file_title
  end

  def create_title(title)
    CSV.open(@file_title, 'w') do |csv|
      csv << title
    end
  end

  def insert_item(items)
    CSV.open(@file_title, 'a') do |csv|
      csv << items
    end
  end
end