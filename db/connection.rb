# connection string
class Connection
  def self.conn
    PG::Connection.new('dbname=slutspurt
    port=5432
    user=slutspurt
    password=slutspurt')
  end
end
