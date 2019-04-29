require 'byebug'
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

    #Distributor.all()
    #Distributor.all() { {join: 'brand'} }
    def self.all(hash = {}, &block)

        #vilka kolumner har jag?

        #@columns

        kalle = nil
        if block_given?
            p @columns
            @columns.each do |column|
                if column.include?(@table_name)
                    kalle = column
                end
            end
            query = conn.exec("SELECT * FROM #{@table_name} JOIN #{block.call.values.first} ON #{block.call.values.first}.id = #{@table_name}.id")#hur ska jag veta att jag ska ha brand.distributorid här?
        end

        byebug
        query = "SELECT * FROM #{@table_name}"
        rows = conn.exec(query)
        #  do |result|
        #     result.each do |row|
        #       brands = []
        #       puts row['id']
        #       conn.exec("SELECT * FROM brand
        #                 WHERE distributorid = #{row['id']}") do |test|
        #         test.each do |test2|
        #           puts test2
        #           brands << test2
        #         end
        #       end
        #       row['brands'] = brands
        #       distributors << row
        #     end
        # end

    end
end