require "date"
require_relative "core/salary"
require_relative "insurance_jp"
require_relative "jp-national-tax/income_tax"

class SalaryJP < Salary

  def initialize(area=nil, date=nil)
    super(date)
    @insurance = InsuranceJP.new(area, date)
  end

  def payment_record(profile)
    {}.tap do |h|
      select_code(profile, 1).each {|k,v| h[k] = v}
      h["201"] = @insurance.health_insurance_salary(insurance_rank(profile))
      h["202"] = @insurance.pension_salary(pension_rank(profile))
      tax_base = sum_code(h,1, income_tax_exception) - h["201"] - h["202"]
      h["203"] = JP::IncomeTax.calc_kouran(tax_base, Date.today, true)
      h["211"] = resident_tax(profile)
      select_code(profile, 3).each {|k,v| h[k] = v}
      select_code(profile, 4).each {|k,v| h[k] = v}
      h.merge!(amount_by_code(h))
      h["payment"] = h["100"] - h["200"] - h["300"] + h["400"]
      h["id"] = profile.dig("id")
    end
  end

  def income_tax_exception
    ["116", "118", "119", "11A", "11B"]
  end

  def insurance_rank(dat)
    take_active_setting(dat, "insurance", "rank")
  end

  def pension_rank(dat)
    take_active_setting(dat, "pension", "rank")
  end

  # todo: use June settings
  def resident_tax(dat)
    take_active_setting(dat, "resident", "ordinal")
  end

end
