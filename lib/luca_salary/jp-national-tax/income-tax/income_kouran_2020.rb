require "date"
require "bigdecimal"

module JP
  module IncomeTax
    module Kouran2020

      module_function

      def effective_date
        Date.parse("2020-01-01")
      end

      #
      # 月額表の甲欄を適用する給与等につき、電子計算機等を使用して源泉徴収税額を計算する方法
      #
      def monthly_kouran (その月の社会保険料等控除後の給与等の金額, 配偶者 = false, 控除対象扶養親族の数 = 0)

        b = その月の社会保険料等控除後の給与等の金額

        配偶者控除の額及び扶養控除の額 = 扶養控除の額 (控除対象扶養親族の数)
        配偶者控除の額及び扶養控除の額 += 配偶者控除の額 if 配偶者

        課税給与所得金額 = b - 配偶者控除の額及び扶養控除の額 - 給与所得控除の額(b) - 基礎控除の額(b)

        源泉徴収額 = 税額(課税給与所得金額).to_i

        if 源泉徴収額 > 0
          源泉徴収額
        else
          0
        end

      end


      def 給与所得控除の額 (その月の社会保険料控除後の給与等の金額)

        case その月の社会保険料控除後の給与等の金額
        when 0 .. 135_416
          45_834
        when 135_417 .. 149_999
          (その月の社会保険料控除後の給与等の金額 * BigDecimal("0.4")).ceil - 8_333
        when 150_000 .. 299_999
          (その月の社会保険料控除後の給与等の金額 * BigDecimal("0.3")).ceil + 6_667
        when 300_000 .. 549_999
          (その月の社会保険料控除後の給与等の金額 * BigDecimal("0.2")).ceil + 36_667
        when 550_000 .. 708_330
          (その月の社会保険料控除後の給与等の金額 * BigDecimal("0.1")).ceil + 91_667
        else
          162_500
        end

      end


      def 配偶者控除の額
        31_667
      end


      def 扶養控除の額 (控除対象扶養親族の数)
        31_667 * 控除対象扶養親族の数
      end


      def 基礎控除の額 (その月の社会保険料等控除後の給与等の金額)

        case その月の社会保険料等控除後の給与等の金額
        when 0 .. 2_162_499
          40_000
        when 2_162_500 .. 2_204_166
          26_667
        when 2_204_167 .. 2_245_833
          13_334
        else
          0
        end

      end


      def 税額 (その月の課税給与所得金額)

        case その月の課税給与所得金額
        when 0 .. 162_500
          (その月の課税給与所得金額 * BigDecimal("0.05105")).round(0, BigDecimal::ROUND_HALF_UP)
        when 162_501 .. 275_000
          (その月の課税給与所得金額 * BigDecimal("0.10210")).round(0, BigDecimal::ROUND_HALF_UP) - 8_296
        when 275_001 .. 579_166
          (その月の課税給与所得金額 * BigDecimal("0.20420")).round(0, BigDecimal::ROUND_HALF_UP) - 36_374
        when 579_001 .. 750_000
          (その月の課税給与所得金額 * BigDecimal("0.23483")).round(0, BigDecimal::ROUND_HALF_UP) - 54_113
        when 750_001 .. 1_500_000
          (その月の課税給与所得金額 * BigDecimal("0.33693")).round(0, BigDecimal::ROUND_HALF_UP) - 130_688
        when 1_500_001 .. 3_333_333
          (その月の課税給与所得金額 * BigDecimal("0.40840")).round(0, BigDecimal::ROUND_HALF_UP) - 237_893
        else
          (その月の課税給与所得金額 * BigDecimal("0.45945")).round(0, BigDecimal::ROUND_HALF_UP) - 408_061
        end

      end

    end
  end
end
