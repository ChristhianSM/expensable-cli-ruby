module Helpers
  def message(message, spaces)
    [
      "####################################",
      "##{' ' * (spaces + 1)}#{message}#{' ' * spaces}#",
      "####################################"
    ].join("\n")
  end

  # Menus
  def logged_menu(options)
    menu_options(options)
  end

  def menu_options(options)
    puts options.join("  |  ")
    print "> "
    action, id = actions
    [action, id]
  end

  def actions
    action, id = gets.chomp.downcase.split # "show 1" -> ["show", "1"]
    if id.to_i.positive?
      [action, id.to_i]
    else
      [action, id]
    end
  end

  def first_menu(options)
    puts options.join("  |  ")
  end

  def second_menu(message, options)
    puts "#{message} #{options.join('  |  ')}"
    puts "<-- back"
    print "> "
    action, id = actions_list
    [action, id]
  end

  def print_user(user)
    firstname = user[:first_name] || "User"
    lastname = user[:last_name] || "Unknown"
    puts "\nWelcome to Expensable #{firstname} #{lastname}\n".green
  end

  def find_by_id(array, id)
    array.find { |object| object[:id] == id }
  end
end
