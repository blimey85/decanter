module Decanter
  module Squasher
    class DateSquasher < Base
      squasher do |name, values, options|
        day = values[0]
        month = values[1]
        year = values[2]
        Date.new(year, month, day)
      end
    end
  end
end
