require 'luca_salary/jp/version'
require 'date'
require 'luca_salary'
require 'luca_salary/jp/insurance'
require 'jp_national_tax'

class LucaSalaryJP < LucaSalary
  def initialize(dir_path, config = nil, date = nil)
    @pjdir = dir_path
    @date = date
    @insurance = InsuranceJP.new(@pjdir, config.dig('jp', 'area'), date)
  end

  # need for local dictionary loading
  def self.country_path
    __dir__
  end

  def calc_payment(profile)
    {}.tap do |h|
      select_code(profile, 1).each { |k, v| h[k] = v }
      h['201'] = @insurance.health_insurance_salary(insurance_rank(profile))
      h['202'] = @insurance.pension_salary(pension_rank(profile))
      tax_base = sum_code(h, 1, income_tax_exception) - h['201'] - h['202']
      h['203'] = JpNationalTax::IncomeTax.calc_kouran(tax_base, Date.today, true)
      h['211'] = resident_tax(profile)
      select_code(profile, 3).each { |k, v| h[k] = v }
      select_code(profile, 4).each { |k, v| h[k] = v }
      h.merge!(amount_by_code(h))
      h['500'] = h['100'] - h['200'] - h['300'] + h['400']
      h['id'] = profile.dig('id')
    end
  end

  def income_tax_exception
    %w[116 118 119 11A 11B]
  end

  def insurance_rank(dat)
    take_active(dat, 'insurance', 'rank')
  end

  def pension_rank(dat)
    take_active(dat, 'pension', 'rank')
  end

  def resident_tax(dat)
    attr = @date.month == 6 ? 'extra' : 'ordinal'
    take_active(dat, 'resident', attr)
  end
end
