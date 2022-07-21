class Dog

    # attr_accessor :name, :breed, :id

    attr_accessor :id

    # def initialize(name:, breed:, id: nil)
    #     @id = id
    #     @name = name
    #     @breed = breed
    # end

    def initialize(attributes)
        @id = nil
        attributes.each do |key, value|
            self.class.attr_accessor(key)
            self.send("#{key}=", value)
        end
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs(name, breed)
        values(?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]

        self
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end 

    def self.all
        sql = <<-SQL
          SELECT *
          FROM dogs
        SQL
    
        DB[:conn].execute(sql).map do |row|
          self.new_from_db(row)
        end
      end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs WHERE 
            dogs.name = name
        SQL

        DB[:conn].execute(sql).map{|row| self.new_from_db(row)}.first
    end

    def self.find(id)
        sql = <<-SQL
            SELECT * 
            FROM dogs WHERE
            dogs.id = ? 
        SQL

        DB[:conn].execute(sql,id).map{|row| self.new_from_db(row)}.first
    end

    def update
       DB[:conn].execute('UPDATE dogs SET name = ? WHERE dogs.name = ?', name) 
    end
end
