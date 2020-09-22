require "date"
Dir[File.expand_path("income-tax/income*.rb", __dir__)].each{|f| require_relative(f)}

module JP
  module IncomeTax
  MOD = [Kouran2020]

    module_function

    def calc_kouran(pay_amount, pay_date, partner = false, dependent = 0)
      responsible_module(pay_date)
        .send(:monthly_kouran, pay_amount, partner, dependent)
        .to_i
    end

    def responsible_module(date = nil)
      if date.nil?
        raise UndefinedDateError
      elsif date.class.name == "String"
        date = Date.parse(date)
      end

      rules = MOD.map{|mod| [mod.send(:effective_date), mod] }.filter{|a| date >= a[0]}

      if rules.length > 0
        rules.sort_by{|a| a[0]}.reverse!.first[1]
      else
        raise NoValidModuleError 
      end
    end

  end
end
