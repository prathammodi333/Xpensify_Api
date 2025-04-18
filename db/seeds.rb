# # This file should ensure the existence of records required to run the application in every environment (production,
# # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# #
# # Example:
# #
# #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
# #     MovieGenre.find_or_create_by!(name: genre_name)
# #   end
# # db/seeds.rb
# require 'faker'

# # Clear existing data to avoid duplicates (optional, comment out for production)

# # Seed Users
# puts "Creating users..."
# users = []
# 10.times do
#   users << User.create!(
#     name: Faker::Name.unique.name,
#     email: Faker::Internet.unique.email,
#     password: 'Passw0rd!', # Meets strong_password: 8+ chars, uppercase, lowercase, digit, special
#     password_confirmation: 'Passw0rd!',
#  # Skip Devise confirmation emails
#     jti: SecureRandom.uuid
#   )
# end

# # Seed Groups
# puts "Creating groups..."
# groups = []
# 5.times do
#   groups << Group.create!(
#     name: Faker::Team.unique.name,
#     created_by: users.sample.id,
#     invite_token: SecureRandom.hex(10) # Unique invite token
#   )
# end

# # Seed Group Memberships
# puts "Creating group memberships..."
# 20.times do
#   user = users.sample
#   group = groups.sample
#   # Avoid duplicate memberships
#   unless GroupMembership.exists?(user_id: user.id, group_id: group.id)
#     GroupMembership.create!(user_id: user.id, group_id: group.id)
#   end
# end

# # Seed Friendships (mutual)
# puts "Creating friendships..."
# friendship_pairs = []
# 15.times do
#   user1, user2 = users.sample(2)
#   next if user1 == user2 || friendship_pairs.include?([user1.id, user2.id]) || friendship_pairs.include?([user2.id, user1.id])

#   # Create one friendship; the after_create callback will create the inverse
#   Friendship.find_or_create_by!(user_id: user1.id, friend_id: user2.id)
#   friendship_pairs << [user1.id, user2.id]
# end

# # Seed Expenses
# puts "Creating expenses..."
# expenses = []
# 10.times do
#   group = groups.sample
#   # Select a user who is a member of the group
#   paid_by = group.users.sample
#   next unless paid_by # Skip if no users in group

#   expenses << Expense.create!(
#     paid_by_id: paid_by.id,
#     group_id: group.id,
#     amount: Faker::Number.between(from: 10.0, to: 100.0).round(2),
#     description: Faker::Commerce.product_name
#   )
# end

# # Seed Expense Shares
# puts "Creating expense shares..."
# 30.times do
#   expense = expenses.sample
#   group = expense.group
#   user = group.users.sample
#   next unless user && user.id != expense.paid_by_id # Skip if no users or user is the payer

#   # Calculate a reasonable amount_owed (split expense amount among members)
#   max_owed = [expense.amount - expense.amount_owed, 0].max
#   next if max_owed <= 0 # Skip if expense is fully shared

#   amount_owed = Faker::Number.between(from: 1.0, to: max_owed).round(2)
#   unless ExpenseShare.exists?(expense_id: expense.id, user_id: user.id)
#     ExpenseShare.create!(
#       expense_id: expense.id,
#       user_id: user.id,
#       amount_owed: amount_owed
#     )
#   end
# end

# # Seed Settlements
# puts "Creating settlements..."
# settlements = []
# 10.times do
#   group = groups.sample
#   # Select two different users from the group
#   payer, payee = group.users.sample(2)
#   next unless payer && payee && payer != payee

#   settlements << Settlement.create!(
#     payer_id: payer.id,
#     payee_id: payee.id,
#     group_id: group.id,
#     amount: Faker::Number.between(from: 5.0, to: 50.0).round(2)
#   )
# end

# # Seed Transaction Histories
# puts "Creating transaction histories..."
# settlements.each do |settlement|
#   TransactionHistory.create!(
#     payer_id: settlement.payer_id,
#     receiver_id: settlement.payee_id,
#     amount: settlement.amount,
#     settlement_id: settlement.id
#   )
# end

# puts "Seeding complete!"
# puts "Created #{User.count} users, #{Friendship.count} friendships, #{Group.count} groups, " \
#      "#{GroupMembership.count} group memberships, #{Expense.count} expenses, " \
#      "#{ExpenseShare.count} expense shares, #{Settlement.count} settlements, " \
#      "#{TransactionHistory.count} transaction histories."
# db/seeds.rb
require 'faker'

puts "Creating users..."
users = []
fixed_users = [
  { name: "Alice Smith", email: "alice.smith@example.com" },
  { name: "Bob Johnson", email: "bob.johnson@example.com" },
  { name: "Charlie Brown", email: "charlie.brown@example.com" },
  { name: "Diana Lee", email: "diana.lee@example.com" },
  { name: "Emma Wilson", email: "emma.wilson@example.com" },
  { name: "Frank Davis", email: "frank.davis@example.com" },
  { name: "Grace Miller", email: "grace.miller@example.com" },
  { name: "Henry Taylor", email: "henry.taylor@example.com" },
  { name: "Isabella Martinez", email: "isabella.martinez@example.com" },
  { name: "James Anderson", email: "james.anderson@example.com" }
]
fixed_users.each do |user_data|
    user = User.find_or_create_by!(email: user_data[:email]) do |u|
      u.name = user_data[:name]
      u.password = 'Passw0rd!'
      u.password_confirmation = 'Passw0rd!'
      u.jti = SecureRandom.uuid
    end
    users << user
  end

# Seed Groups
puts "Creating groups..."
groups = []
5.times do |i|
  name = Faker::Team.unique.name
  group = Group.find_or_create_by!(name: name) do |g|
    g.created_by = users.sample.id
    g.invite_token = SecureRandom.hex(10) # Unique invite token
  end
  groups << group
end

# Seed Group Memberships
puts "Creating group memberships..."
20.times do
  user = users.sample
  group = groups.sample
  GroupMembership.find_or_create_by!(user_id: user.id, group_id: group.id)
end

# Ensure All Group Members Are Friends
puts "Ensuring all group members are friends..."
groups.each do |group|
  # Convert CollectionProxy to Array to use combination
  group_users = group.users.to_a
  # Create friendships for all pairs of users
  group_users.combination(2).each do |user1, user2|
    Friendship.find_or_create_by!(user_id: user1.id, friend_id: user2.id)
  end
end

# Note: No standalone friendships section, as group memberships create sufficient friendships.
# If additional random friendships are needed, they can be added here.

# Seed Expenses
puts "Creating expenses..."
expenses = []
10.times do
  group = groups.sample
  # Select a user who is a member of the group
  paid_by = group.users.sample
  next unless paid_by # Skip if no users in group

  description = Faker::Commerce.product_name
  expense = Expense.find_or_create_by!(group_id: group.id, description: description) do |e|
    e.paid_by_id = paid_by.id
    e.amount = Faker::Number.between(from: 10.0, to: 100.0).round(2)
  end
  expenses << expense
end

# Seed Expense Shares
puts "Creating expense shares..."
30.times do
  expense = expenses.sample
  group = expense.group
  user = group.users.sample
  next unless user && user.id != expense.paid_by_id # Skip if no users or user is the payer

  # Calculate a reasonable amount_owed (split expense amount among members)
  max_owed = [expense.amount - expense.amount_owed, 0].max
  next if max_owed <= 0 # Skip if expense is fully shared

  amount_owed = Faker::Number.between(from: 1.0, to: max_owed).round(2)
  ExpenseShare.find_or_create_by!(expense_id: expense.id, user_id: user.id) do |es|
    es.amount_owed = amount_owed
  end
end

# Seed Settlements
puts "Creating settlements..."
settlements = []
10.times do
  group = groups.sample
  # Select two different users from the group (they are guaranteed to be friends)
  payer, payee = group.users.sample(2)
  next unless payer && payee && payer != payee

  # Calculate the amount owed by payer to payee in this group
  amount_owed = payer.group_balances(group)[payee.id] || 0
  next unless amount_owed > 0 # Skip if payer doesn't owe payee

  # Set settlement amount between 0.01 and amount_owed
  amount = Faker::Number.between(from: 0.01, to: amount_owed).round(2)
  settlement = Settlement.find_or_create_by!(payer_id: payer.id, payee_id: payee.id, group_id: group.id, amount: amount)
  settlements << settlement
end

# Seed Transaction Histories
puts "Creating transaction histories..."
settlements.each do |settlement|
  TransactionHistory.find_or_create_by!(settlement_id: settlement.id) do |th|
    th.payer_id = settlement.payer_id
    th.receiver_id = settlement.payee_id
    th.amount = settlement.amount
  end
end

puts "Seeding complete!"
puts "Created #{User.count} users, #{Friendship.count} friendships, #{Group.count} groups, " \
     "#{GroupMembership.count} group memberships, #{Expense.count} expenses, " \
     "#{ExpenseShare.count} expense shares, #{Settlement.count} settlements, " \
     "#{TransactionHistory.count} transaction histories."