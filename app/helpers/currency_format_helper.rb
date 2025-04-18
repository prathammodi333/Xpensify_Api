module CurrencyFormatHelper
    def currency_format(amount)
        number_to_currency(amount || 0, unit: "$", precision: 2)
      end
end
