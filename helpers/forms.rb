module Forms
  def login_form
    email = validate_email
    password = validate_password
    { email: email, password: password }
  end

  def validate_password(prompt = "Password")
    password = ""
    loop do
      pattern = /^\S{6,}$/
      password = get_string(prompt, required: true, password: true)
      puts "* Minimum 6 characters".red unless password.match?(pattern)
      break if password.match?(pattern)
    end
    password
  end

  def validate_email
    email = ""
    loop do
      pattern = /^\S[^._,-]+@+[a-z]+[.]+[a-z]+$/
      email = get_string("Email", required: true)
      puts "* Invalid format".red unless email.match?(pattern)
      break if email.match?(pattern)
    end
    email
  end

  def validate_confirmation_password
    password = ""
    loop do
      password = validate_password
      confirm_password = validate_password("Confirm Password")
      break if password == confirm_password

      puts "* Passwords do not match".red
    end
    password
  end

  def create_user_form(type = "create")
    phone = ""
    if type == "create"
      email = validate_email
      password = validate_confirmation_password
    end
    lastname = get_string("Last name")
    firstname = get_string("First name")

    loop do
      pattern = /\A(\+51\s)?\d{3}\d{3}\d{3}\z/
      phone = get_string("Phone")
      break if phone.nil? || phone.match?(pattern)

      puts "* Required format: +51 111222333 or 111222333".red unless phone.match?(pattern)
    end
    if type == "create"
      { email: email, password: password, last_name: lastname, first_name: firstname, phone: phone }
    else
      { last_name: lastname, first_name: firstname, phone: phone }
    end
  end

  def create_category_form
    name = get_string("Name", required: true)
    transaction_type = ""
    loop do
      transaction_type = get_string("Transaction type", required: true).downcase
      break if ["expense", "income"].include?(transaction_type)

      puts "* Only income or expense".red unless ["income", "expense"].include?(transaction_type)
    end
    color = ""
    array_colors = ["blue", "green", "red", "yellow"]
    loop do
      puts "#{'Availables colors :'.light_blue} #{array_colors.join(' | ')} (Default: white)"
      color = get_string("Color")
      break if color.nil? || array_colors.include?(color.downcase)

      puts "Select available colors" unless array_colors.include?(color.downcase)
    end
    color = "teal" if color.nil?
    { name: name, transaction_type: transaction_type, color: color, icon: "bank" }
  end

  def transaction_form
    amount = ""
    loop do
      amount = get_string("Amount", required: true).to_i
      break if amount.positive?

      puts "* Amount Cannot be zero".red
    end

    date = get_string("Date", required: true)
    date = validate_date(date)

    notes = get_string("Notes")
    { amount: amount, date: date, notes: notes }
  end

  def get_string(label, required: false, password: false)
    input = ""
    loop do
      print "#{label}: ".light_blue
      if password
        input = $stdin.noecho(&:gets).chomp
        puts ""
      else
        input = gets.chomp
      end
      break unless input.empty? && required

      puts "* #{label} can't be blank".red
    end
    input.empty? ? nil : input
  end
end
