require 'luca_salary/jp/version'
require 'date'
require 'luca_salary'
require 'luca_salary/jp/insurance'
require 'jp_national_tax'

class LucaSalary::Jp < LucaSalary::Base
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
      select_code(profile, '1').each { |k, v| h[k] = v }
      h['201'] = @insurance.health_insurance_salary(insurance_rank(profile))
      h['202'] = @insurance.pension_salary(pension_rank(profile))
      tax_base = sum_code(h, '1', income_tax_exception) - h['201'] - h['202']
      h['203'] = JpNationalTax::IncomeTax.calc_kouran(tax_base, Date.today, true)
      h['211'] = resident_tax(profile)
      select_code(profile, '3').each { |k, v| h[k] = v }
      select_code(profile, '4').each { |k, v| h[k] = v }
      h.merge!(amount_by_code(h))
      h['id'] = profile.dig('id')
    end
  end

  def self.year_total(payment)
    payment.tap do |p|
      p['911'] = basic_deduction(p['1'])
      p['916'] = partner_deduction(p['1'])
      p['912'] = (p['201'] || 0) + (p['202'] || 0)
      p['901'] = year_salary(p['1'])
      p['941'] = p['901'] - p['911'] - p['912'] - p['916']
      p['961'] = year_tax(p['941'])
      diff = p['961'] - p['203']
      if diff.positive?
        p['3A1'] = diff
      else
        p['4A1'] = diff * -1
      end
    end
  end

  def self.year_salary(income)
    rounded = if income < 1_619_000
                income
              elsif income < 1_620_000
                income - ((income - 1_619_000) % 1_000)
              elsif income < 1_624_000
                income - ((income - 1_620_000) % 2_000)
              elsif income < 1_624_000
                income - ((income - 1_624_000) % 4_000)
              else
                income
              end
    if rounded < 551_000
      0
    elsif rounded < 1_619_000
      rounded - 550_000
    elsif rounded < 1_620_000
      rounded * 0.6 + 97_600
    elsif rounded < 1_622_000
      rounded * 0.6 + 98_000
    elsif rounded < 1_624_000
      rounded * 0.6 + 98_800
    elsif rounded < 1_628_000
      rounded * 0.6 + 99_600
    elsif rounded < 1_800_000
      rounded * 0.6 + 100_000
    elsif rounded < 3_600_000
      rounded * 0.7 - 80_000
    elsif rounded < 6_600_000
      rounded * 0.8 - 440_000
    elsif rounded < 8_500_000
      rounded * 0.9 - 1_100_000
    else
      rounded - 1_950_000
    end
  end

  def self.year_tax(income)
    tax = if income < 1_950_000
            income * 0.05
          elsif income <= 3_300_000
            income * 0.1 - 97_500
          elsif income <= 6_950_000
            income * 0.2 - 427_500
          elsif income <= 9_000_000
            income * 0.23 - 636_000
          elsif income <= 18_000_000
            income * 0.33 - 1_536_000
          elsif income <= 18_050_000
            income * 0.4 - 2_796_000
          else
            raise "no target"
          end
    (tax / 1000).floor * 1000
  end

  def self.basic_deduction(income)
    if income <= 24_000_000
      480_000
    elsif income <= 24_500_000
      320_000
    elsif income <= 25_000_000
      160_000
    else
      0
    end
  end

  def self.partner_deduction(income)
    if income <= 9_000_000
      380_000
    elsif income <= 9_500_000
      260_000
    elsif income <= 10_000_000
      130_000
    else
      0
    end
  end

  def income_tax_exception
    %w[116 118 119 11A 11B]
  end

  def insurance_rank(dat)
    dat.dig('insurance', 'rank')
  end

  def pension_rank(dat)
    dat.dig('pension', 'rank')
  end

  def resident_tax(dat)
    attr = @date.month == 6 ? 'extra' : 'ordinal'
    dat.dig('resident', attr)
  end
end
