require 'bcrypt'
require 'yaml'

users = Psych.load_file('users.yaml')

p users

hashed_pw = BCrypt::Password.new(users["james"])
p hashed_pw == 'pizza'

lists = []
lists << {
  name: 'list1',
  items: ['pizza', 'doritos', 'apples']
}

File.write('output.yml', Psych.dump(lists))