require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_many :persons, dependent: :destroy
end

class Person < ActiveRecord::Base
    self.table_name = 'persons'
    belongs_to :user
end