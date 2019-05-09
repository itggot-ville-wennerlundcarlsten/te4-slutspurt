require 'byebug'
# Orm code
class Model
  def self.conn
    @conn ||= Connection.conn
  end

  def self.table_name(name)
    @table_name = name
  end

  def self.column(column_name)
    @columns ||= []
    @columns << column_name
  end

  # Distributor.all()
  # Distributor.all() { {join: 'brand'} }
  def self.all(_hash = {}, &block)
    # vilka kolumner har jag?
    # @columns
    kalle = nil
    if block_given?
      @columns.each do |column|
        kalle = column if column.include?(@table_name)
      end
      query = "SELECT #{@table_name}.id AS #{@table_name}_id,
       #{@table_name}.name AS #{@table_name}_name,
       #{block.call.values.first}.id AS #{block.call.values.first}_id,
       #{block.call.values.first}.name AS #{block.call.values.first}_name,
       #{block.call.values.first}.#{block.call.values.last}
       AS #{@table_name}_#{block.call.values.last}
       FROM #{@table_name} JOIN #{block.call.values.first}
       ON #{block.call.values.first}.#{block.call.values.last}
       = #{@table_name}.id"
    end
    # byebug
    # query = "SELECT * FROM #{@table_name}"
    conn.exec(query)
  end

  def self.get(hash = {}, &block); end
end
