require "terminal-table"
require "date"
require "colorize"
require "io/console"
require_relative "helpers/helpers"
require_relative "helpers/forms"
require_relative "helpers/validates"
require_relative "services/sessions"
require_relative "services/user"
require_relative "services/categories"
require_relative "services/transaction"
# Start here. Happy coding!

class Expensable
  include Helpers
  include Forms

  def initialize
    @user = nil
    @categories = []
    @mode = "expense"
    @transaction = []
    @date = DateTime.now
  end

  def start
    puts "\n#{message('Welcome to Expensable', 6)} \n\n"
    action = ""
    until action == "exit"
      action, _id = menu_options(["login", "create_user", "exit"])
      case action
      when "login" then login
      when "create_user" then create_user
      when "exit" then puts "\n#{message('Thanks for using Expensable', 3)} \n\n"
      else
        puts "\n ----Invalid action ----\n".red
      end
    end
  end

  def login
    credentials = login_form
    @user = Services::Sessions.login(credentials)
    print_user(@user)
    logged_page
  rescue HTTParty::ResponseError => e
    parsed_error = JSON.parse(e.message)
    puts "\n-----#{parsed_error['errors'][0]}-----\n".red
  end

  def create_user
    credentials = create_user_form
    @user = Services::User.signup(credentials)
    print_user(@user)
    logged_page
  rescue HTTParty::ResponseError => e
    parsed_error = JSON.parse(e.message)
    puts "\n-----#{parsed_error['errors'][0]}-----\n".red
  end

  def show_table
    month = @date.mon
    year = @date.year
    array_categories = @categories.select { |category| category[:transaction_type] == @mode }
    array_categories.map do |row|
      total = 0
      row[:transactions].each do |transaction|
        year_t, month_t, _day_t = transaction[:date].split("-")
        total += transaction[:amount] if year_t.to_i == year && month_t.to_i == month
      end
      name = row[:color] == "teal" ? row[:name] : row[:name].colorize(row[:color].to_sym)
      [row[:id], name, total]
    end
  end

  def table(title, headings, message, array_rows, type, columns)
    table = Terminal::Table.new
    table.title = title.join("\n")
    table.headings = headings
    if array_rows.length.zero?
      table.add_row [{ value: message.red, colspan: columns, alignment: :center }]
    else
      table.rows = if type == "categories"
                     array_rows
                   else
                     array_rows.map do |row|
                       date = Date.parse(row[:date])
                       [row[:id], date.strftime("%a, %b %d"), row[:amount], row[:notes]]
                     end
                   end
    end
    table
  end

  def logged_page
    @categories = Services::Category.index_categories(@user[:token])

    action = ""
    until action == "logout"
      puts table([@mode.capitalize, @date.strftime("%B %Y")], ["ID", "Category", "Total"],
                 "THERE IS NO CATEGORIES TO SHOW", show_table, "categories", 3)
      first_menu(["create", "show ID", "update ID", "delete ID"])
      action, id = logged_menu(["add-to ID", "toggle", "next", "prev", "update_user", "logout"])
      case action
      when "create" then create_category
      when "show" then show_transactions(id.to_i)
      when "update" then update_category(id.to_i)
      when "delete" then delete_category(id.to_i)
      when "add-to" then add_transaction(id.to_i)
      when "toggle" then toggle_category
      when "next" then @date = @date.next_month
      when "prev" then @date = @date.prev_month
      when "update_user" then update_user
      when "logout" then logout
      else
        puts "\n-----Invalid Option-----\n".red
      end
    end
    action
  end

  def create_category
    hash_data = create_category_form
    new_category = Services::Category.create_category(@user[:token], hash_data)
    @categories << new_category
  rescue HTTParty::ResponseError => e
    parsed_error = JSON.parse(e.message)
    puts "\n-----#{parsed_error['errors'][0]}-----\n".red
  end

  def update_category(id)
    if find_by_id(@categories, id)
      hash_data = create_category_form
      found_category = @categories.find { |category| category[:id] == id }
      found_category.update(**hash_data)
      Services::Category.update_category(@user[:token], hash_data, id)
    else
      puts "\n-----Enter a Id Valid-----\n".red
    end
  end

  def delete_category(id)
    if find_by_id(@categories, id)
      found_category = @categories.find { |category| category[:id] == id }
      @categories.delete(found_category)
      Services::Category.delete_category(@user[:token], id)
    else
      puts "\n-----Enter a Id Valid-----\n".red
    end
  end

  def update_user
    data_user = create_user_form("update")
    @user = Services::User.update_user(@user[:token], data_user)
    puts "\n-User Updated successfully\n".green
  end

  def logout
    Services::Sessions.logout(@user[:token])
    puts "Bye #{@user[:first_name]}\n\n"
    puts message("Welcome to Expensable", 6)
  end

  def toggle_category
    @mode = if @mode == "expense"
              "income"
            else
              "expense"
            end
  end

  def show_transactions_now
    month = @date.mon
    year = @date.year
    array_new = []
    @transaction.each do |transaction|
      year_t, month_t, _day_t = transaction[:date].split("-")
      array_new.push(transaction) if year_t.to_i == year && month_t.to_i == month
    end
    array_new.sort { |a, b| Date.parse(a[:date]) <=> Date.parse(b[:date]) }
  end

  def show_transactions(id_category)
    if find_by_id(@categories, id_category)
      @transaction = Services::Transaction.index_transactions(@user[:token], id_category)
      action = ""
      name_category = find_by_id(@categories, id_category)[:name].capitalize
      until action == "logout"
        puts table([name_category, @date.strftime("%B %Y")], ["ID", "Date", "Amount", "Notes"],
                   "THERE IS NO TRANSACTIONS TO SHOW", show_transactions_now, "transactions", 4)
        first_menu(["add", "update ID", "delete ID"])
        action, id = logged_menu(["next", "prev", "back"])
        case action
        when "add" then add_transaction(id_category.to_i)
        when "update" then update_transaction(id_category.to_i, id.to_i)
        when "delete" then delete_transaction(id_category.to_i, id.to_i)
        when "next" then @date = @date.next_month
        when "prev" then @date = @date.prev_month
        when "back" then break
        else
          puts "\n-----Invalid Option-----\n".red
        end
      end
      action
    else
      puts "\n-----Enter a Id Valid-----\n".red
    end
  end

  def add_transaction(id)
    if find_by_id(@categories, id)
      transaction = transaction_form
      new_transaction = Services::Transaction.create_transaction(@user[:token], transaction, id)
      @transaction << new_transaction
      @categories = Services::Category.index_categories(@user[:token])
    else
      puts "\n-----Enter a Id Valid for Add-----\n".red
    end
  end

  def update_transaction(id_category, id_transaction)
    if find_by_id(@transaction, id_transaction)
      transaction = transaction_form
      found_transaction = @transaction.find { |item| item[:id] == id_transaction }
      # Comprobamos si las notas estab vacias.
      transaction[:notes] = found_transaction[:notes] if transaction[:notes].nil?
      found_transaction.update(**transaction)
      Services::Transaction.update_transaction(@user[:token], transaction, id_category, id_transaction)
    else
      puts "\n-----Enter a Id Valid for update-----\n".red
    end
  end

  def delete_transaction(id_category, id_transaction)
    if find_by_id(@transaction, id_transaction)
      found_transaction = @transaction.find { |transaction| transaction[:id] == id_transaction }
      @transaction.delete(found_transaction)
      Services::Transaction.delete_transaction(@user[:token], id_category, id_transaction)
    else
      puts "\n-----Enter a Id Valid for delete-----\n".red
    end
  end
end

app = Expensable.new
app.start

# christhian2524@gmail.com
