class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end 
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
    self
  end
  
  def self.create(hash_attr) 
    new_dog = self.new(name: hash_attr[:name], breed: hash_attr[:breed])
    new_dog.save
    new_dog
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id, name, breed)
  end
end