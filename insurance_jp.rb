require "bigdecimal"
require "date"
require "json"
require "pathname"

class InsuranceJP
  attr_reader :table

  DATA_DIR = File.expand_path("../dict/", __dir__)

  # load config
  def initialize(area=nil, date=nil)
    @area = area
    @date = date
    @table = load_table(area, date)
  end

  def load_table(area, date)
    file_name = Pathname(DATA_DIR) + select_active_filename
    JSON.parse(File.read(file_name.to_s))
  end

  def health_insurance_salary(rank)
    round6(select_health_insurance(rank).dig("insurance_elder_salary"))
  end

  def pension_salary(rank)
    round6(select_pension(rank).dig("pension_salary"))
  end

  def select_health_insurance(rank)
    @table["fee"].filter{|h| h["rank"] == rank}.first
  end

  def select_pension(rank)
    @table["fee"].filter{|h| h["pension_rank"] == rank}.first
  end

  private

  def round6(num)
    BigDecimal(num).round(0, BigDecimal::ROUND_HALF_DOWN).to_i
  end

  # todo: need selection logic
  def select_active_filename
    list = self.class.load_json
    list.first[1]
  end

  def self.load_json
    table_list = [].tap do |a|
      open_tables do |f, name|
        data = JSON.parse(f.read)
        a << [Date.parse(data["effective_date"]), name]
      end
    end
  end

  def self.open_tables
    Dir.chdir(DATA_DIR) do
      Dir.glob("*.json").each do |file_name|
        File.open(file_name, 'r') {|f| yield(f, file_name)}
      end
    end
  end

end
