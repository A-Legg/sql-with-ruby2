require "database_connection"

class SqlExercise

  attr_reader :database_connection

  def initialize
    @database_connection = DatabaseConnection.new
  end

  def all_customers
    database_connection.sql("SELECT * from customers")
  end

  def limit_customers(num)
    num.to_s.gsub!(/;.*$/, '')

    database_connection.sql("select * from customers limit #{num.to_i}")
  end

  def order_customers(string)
    string.gsub!(/;.*/, '')

    database_connection.sql("select * from customers order by name #{string}")
  end

  def id_and_name_for_customers
    database_connection.sql("select id,name from customers")
  end

  def all_items
    database_connection.sql("select * from items")
  end

  def find_item_by_name(name)
    name.gsub!(/;.*/, '')
    name = nil if name == "'"

    element = database_connection.sql("select * from items where name = '#{name}'")
    element.length == 0 ? nil : element.first
  end

  def count_customers
    database_connection.sql("select count(*) from customers").first["count"].to_i
  end

  def sum_order_amounts
    database_connection.sql("select sum(amount) from orders").first["sum"].to_f
  end

  def minimum_order_amount_for_customers
    database_connection.sql("select customer_id,min(amount) from orders group by customer_id")
  end
  def customer_order_totals
    database_connection.sql("select orders.customer_id, customers.name, sum(orders.amount) from orders inner join customers on orders.customer_id = customers.id group by orders.customer_id, customers.name")

  end

  def items_ordered_by_user(num)
    names = database_connection.sql("select items.name from items inner join orderitems on orderitems.item_id = items.id inner join orders on orderitems.order_id = orders.id where orders.customer_id = #{num}").dup

    names.collect {|name| name["name"]}

  end

  def customers_that_bought_item(item_name)

    command = <<-SQL
      select customers.name as customer_name,customers.id from items
      inner join orderitems on orderitems.item_id = items.id
      inner join orders on orderitems.order_id = orders.id
      inner join customers on orders.customer_id = customers.id
      where items.name = '#{item_name}'
      group by customers.name, customers.id
    SQL
    database_connection.sql(command)
  end

  def customers_that_bought_item_in_state (item_name, state)
    command = <<-SQL
      select customers.* from items
      inner join orderitems on orderitems.item_id = items.id
      inner join orders on orderitems.order_id = orders.id
      inner join customers on orders.customer_id = customers.id
      where items.name = '#{item_name}' and customers.state = '#{state}'
      group by customers.name, customers.id
    SQL
    database_connection.sql(command).first

  end



end
