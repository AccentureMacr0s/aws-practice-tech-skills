require 'digest'

# Generate a unique ID using the current timestamp and a random number
def generate_unique_id
  timestamp = Time.now.to_i.to_s # Current timestamp in seconds
  random_number = rand(1_000_000).to_s # Generate a random number
  unique_string = timestamp + random_number
  unique_id = Digest::SHA256.hexdigest(unique_string)[0, 16] # Hash and truncate
  unique_id
end

# Print the generated unique ID
puts "Generated Unique ID: #{generate_unique_id}"