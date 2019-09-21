class Dog
  attr_accessor :name, :breed 
  attr_reader :id
  def initialize(id: nil, name: name, breed: breed)
    @id = id 
    @name = name 
    @breed = breed
  end 
  
  
  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end
  
  def self.drop_table 
    DB[:conn].execute("DROP TABLE dogs")
  end
  
  def save 
    sql= <<-SQL
      INSERT INTO dogs(name,breed) 
      VALUES(?,?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed) 
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
    self
  end 
  
  def self.create(name:, breed:) 
    new_dog = Dog.new(name: name, breed: breed) 
    new_dog.save
  end
  
  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:, breed:) 
    found = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name, breed) 
    if found == [] 
      self.create(name: name, breed: breed)
    else 
      found.map do |row| 
        self.new_from_db(row) 
      end.first
    end
  end
  
  def self.find_by_name(name) 
     found = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?" ,name).map do |row| 
       self.new_from_db(row)
     end.first
  end 
  
  def update  
    if @id 
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed , self.id ) 
      self
    end
  end
end