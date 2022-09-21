def message_validation(month, day)
  message = "YYYY-MM-DD"
  message = "Enter a mount valid".red if month > 12
  message = "Enter a day valid".red if day > 31
  message = "Enter a month valid and a day valid" if day > 31 && month > 12
  message
end

def validate_date(date)
  y, m, d = date.split "-"
  valid = Date.valid_date?(y.to_i, m.to_i, d.to_i)
  message = message_validation(m.to_i, d.to_i)

  until valid
    puts "* Type a valid date: #{message}".red
    print "Date: ".light_blue
    date = gets.chomp

    y, m, d = date.split "-"
    valid = Date.valid_date?(y.to_i, m.to_i, d.to_i)
    message = message_validation(m.to_i, d.to_i)
  end
  date
end
