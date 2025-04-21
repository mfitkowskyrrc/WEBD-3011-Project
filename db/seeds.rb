require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'image_processing/mini_magick'

CartItem.destroy_all
OrderItem.destroy_all
Product.destroy_all
Order.destroy_all
Cart.destroy_all
Customer.destroy_all
Event.destroy_all
Content.destroy_all
AdminUser.destroy_all

AdminUser.find_or_create_by!(email: "ash@example.com") do |admin|
  admin.password = "password"
  admin.password_confirmation = "password"

  puts "admin user created"
end

Content.create!(
  section: 'contact_us',
  content: <<~HTML
    <p>We're always happy to hear from you! You can reach us through the following channels:</p>
    <ul>
      <li><strong>Phone:</strong> <a href="tel:+1234567891">(123) 456-7890</a></li>
      <li><strong>Email:</strong> <a href="mailto:info@gamehaven.com">info@gamehaven.com</a></li>
      <li><strong>Location:</strong> 42 Tatooine Way, Winnipeg, MB 12345</li>
    </ul>
    <p>Visit us in-store or reach out online, and we’ll be happy to assist you!</p>
  HTML
)
puts "contact us created"

Content.create!(
  section: 'about_us',
  content: <<~HTML
    <p>Welcome to <strong>Game Haven</strong>, your local destination for <em>Trading Card Games</em>, <em>board games</em>, and <em>gaming accessories</em>. For the past five years, we've built a loyal community of tabletop gamers, and now, we're expanding our reach with a new e-commerce platform. Our website makes it easy to <strong>browse our products</strong>, <strong>check availability</strong>, and <strong>shop securely</strong>, all while staying connected with our local events and in-store activities. Whether you're a seasoned gamer or just starting out, <strong>Game Haven</strong> is here to help you level up your gaming experience.</p>
  HTML
)
puts "about us created"

customers = [
  { name: "Ash", email: "ash@example.com", address: "Pallet Town", province: "Manitoba", postal_code: "12345", password: "password", admin: true },
  { name: "Misty", email: "misty@example.com", address: "Cerulean City", province: "Ontario", postal_code: "67890", password: "password", admin: false },
  { name: "Brock", email: "brock@example.com", address: "Pewter City", province: "Alberta", postal_code: "11223", password: "password", admin: false }
]

customers.each do |customer_data|
  Customer.find_or_create_by!(email: customer_data[:email]) do |customer|
    customer.name = customer_data[:name]
    customer.address = customer_data[:address]
    customer.province = customer_data[:province]
    customer.postal_code = customer_data[:postal_code]
    customer.password = customer_data[:password]
    customer.admin = customer_data[:admin]
  end
  puts "Created #{customer_data[:name]}"
end

events = [
  {
    title: "Friday Night Magic",
    description: "standard format",
    start_time: Date.today.next_occurring(:friday) + 19.hours,
    end_time: Date.today.next_occurring(:friday) + 22.hours
  },
  {
    title: "Board Game Night",
    description: "try some new stuff or play classics",
    start_time: Date.today + 10.days + 18.hours,
    end_time: Date.today + 10.days + 21.hours
  },
  {
    title: "Yu-Gi-Oh Locals",
    description: "duel time",
    start_time: Date.today + 2.days + 14.hours,
    end_time: Date.today + 2.days + 17.hours
  },
  {
    title: "Pokemon League",
    description: "casual play",
    start_time: Date.today + 6.days + 12.hours,
    end_time: Date.today + 6.days + 14.hours
  },
  {
    title: "Learn to Play D&D",
    description: "one-shot",
    start_time: Date.today + 17.days + 13.hours,
    end_time: Date.today + 17.days + 17.hours
  }
]

events.each do |event|
  Event.create!(event)
  puts "Created #{event[:title]}"
end

def fetch_and_create_products_from_bgg(url, category_type)
  category = Category.find_or_create_by(name: category_type)

  response = HTTParty.get(url)
  xml_data = Nokogiri::XML(response.body)

  item_ids = xml_data.xpath('//item').map { |item| item['id'] }
  item_ids = item_ids.take(20)
  item_ids.map(&:to_i)

  item_ids.each_slice(10) do |batch|
    item_ids_string = batch.join(',')
    item_url = "https://www.boardgamegeek.com/xmlapi2/thing?id=#{item_ids_string}"

    item_response = HTTParty.get(item_url)
    item_xml_data = Nokogiri::XML(item_response.body)

    product_data = item_xml_data.xpath('//item').map do |item|
      name = item.xpath('name[@type="primary"]').attr('value').text.strip
      image_url = item.xpath('image').text.strip
      description = item.xpath('description').text.strip
      description = CGI.unescapeHTML(description)
      description.gsub!(/&#10;/, "\n")
      description.gsub!(/&mdash;/, '—')
      description.gsub!(/&quot;/, '"')
      description.gsub!(/&apos;/, "'")
      description.gsub!(/&amp;/, '&')

      {
        name: name,
        description: description,
        category_id: category.id,
        price: Faker::Number.decimal(l_digits: 2, r_digits: 3),
        stock_quantity: 10
      }
    end

    Product.insert_all(product_data) if product_data.any?

    product_data.each do |product|
      process_product_image(product[:name], item_xml_data.xpath('//item').find { |item| item.xpath('name[@type="primary"]').attr('value').text.strip == product[:name] }&.xpath('image')&.text)
    end

    puts "#{category.name} products added - #{product_data.map { |p| p[:name] }.join(', ')}"
    sleep(2)
  end
end

def process_product_image(name, image_url)
  return unless image_url.present?

  begin
    image_file = URI.open(image_url)
    temp_input_file = Tempfile.new([ "#{name.parameterize}", File.extname(image_url) ])
    IO.copy_stream(image_file, temp_input_file)
    image = MiniMagick::Image.open(temp_input_file.path)

    temp_output_file = Tempfile.new([ "#{name.parameterize}", ".webp" ])
    image.format("webp") { |cmd| cmd.auto_orient }
    image.write(temp_output_file.path)

    product = Product.find_by(name: name)
    if product
      product.image.attach(io: File.open(temp_output_file.path), filename: "#{name.parameterize}.webp", content_type: "image/webp")
    end
  rescue MiniMagick::Error => e
    Rails.logger.error("Image processing failed for #{name}: #{e.message}")
  ensure
    temp_input_file.close
    temp_input_file.unlink
    temp_output_file.close
    temp_output_file.unlink
  end
end

def fetch_and_create_products_from_tcgdex(set_id, category_type)
  category = Category.find_or_create_by(name: category_type)
  product_names = []

  set_url = "https://api.tcgdex.net/v2/en/sets/#{set_id}"
  set_response = HTTParty.get(set_url)
  set_data = set_response.parsed_response

  card_ids = set_data['cards'].map { |card| card['id'] }.first(30)

  card_ids.each do |card_id|
    card_url = "https://api.tcgdex.net/v2/en/cards/#{card_id}"
    card_response = HTTParty.get(card_url)
    card_data = card_response.parsed_response

    name = card_data['name']
    set_name = card_data['set']['name']
    local_id = card_data['localId']
    description = card_data['text'] || "This card is card number #{local_id} of #{set_name}."
    image_url = card_data['image']
    webp_image_url = "#{image_url}/low.webp"

    product = Product.create!(
      name: name,
      description: description,
      category_id: category.id,
      price: Faker::Number.decimal(l_digits: 2, r_digits: 3),
      stock_quantity: 10
    )

    product_names << name

    if image_url.present?
      image_file = URI.open(webp_image_url)
      product.image.attach(io: image_file, filename: "#{name.parameterize}.webp", content_type: "image/webp")
    end
    sleep(0.3)
  end

  puts "#{category.name} cards added - #{product_names.join(', ')}"
end



hot_board_games_url = "https://boardgamegeek.com/xmlapi2/hot?type=boardgame"
category_type = "Board Game"
fetch_and_create_products_from_bgg(hot_board_games_url, category_type)

hot_rpg_url = "https://boardgamegeek.com/xmlapi2/hot?type=rpg"
category_type = "Role Playing Game"
fetch_and_create_products_from_bgg(hot_rpg_url, category_type)

hot_video_game_url = "https://boardgamegeek.com/xmlapi2/hot?type=videogame"
category_type = "Video Game"
fetch_and_create_products_from_bgg(hot_video_game_url, category_type)

set_id = "base1"
category_type = "Pokemon Card"
fetch_and_create_products_from_tcgdex(set_id, category_type)

if Rails.env.development?
  AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
    admin.password = 'password'
    admin.password_confirmation = 'password'
  end
end
