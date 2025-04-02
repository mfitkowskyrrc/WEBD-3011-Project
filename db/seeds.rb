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

customers = [
  { name: "Ash", email: "ash@example.com", address: "Pallet Town", password: "password" },
  { name: "Misty", email: "misty@example.com", address: "Cerulean City", password: "password" },
  { name: "Brock", email: "brock@example.com", address: "Pewter City", password: "password" }
]

customers.each do |customer_data|
  Customer.find_or_create_by!(email: customer_data[:email]) do |customer|
    customer.name = customer_data[:name]
    customer.address = customer_data[:address]
    customer.password = customer_data[:password]
  end
end


def fetch_and_create_products_from_bgg(url, category_type)
  category = Category.find_or_create_by(name: category_type)

  response = HTTParty.get(url)
  xml_data = Nokogiri::XML(response.body)

  item_ids = xml_data.xpath('//item').map { |item| item['id'] }
  item_ids = item_ids.take(30)
  item_ids.map(&:to_i)

  item_ids.each_slice(15) do |batch|
    item_ids_string = batch.join(',')

    item_url = "https://www.boardgamegeek.com/xmlapi2/thing?id=#{item_ids_string}"

    item_response = HTTParty.get(item_url)
    item_xml_data = Nokogiri::XML(item_response.body)

    item_xml_data.xpath('//item').each do |item|
      name = item.xpath('name[@type="primary"]').attr('value').text.strip
      image_url = item.xpath('image').text.strip

      description = item.xpath('description').text.strip
      description = CGI.unescapeHTML(description)
      description.gsub!(/&#10;/, "\n")
      description.gsub!(/&mdash;/, '—')
      description.gsub!(/&quot;/, '"')
      description.gsub!(/&apos;/, "'")
      description.gsub!(/&amp;/, '&')

      product = Product.create!(
        name: name,
        description: description,
        category_id: category.id,
        price: Faker::Number.decimal(l_digits: 2, r_digits: 3),
        stock_quantity: 10
      )

      if image_url.present?
        image_file = URI.open(image_url)
        temp_input_file = Tempfile.new(["#{name.parameterize}", File.extname(image_url)])
        IO.copy_stream(image_file, temp_input_file)
        image = MiniMagick::Image.open(temp_input_file.path)

        if image.type.downcase == "webp"
          product.image.attach(io: File.open(temp_input_file.path), filename: "#{name.parameterize}.webp", content_type: "image/webp")
        else
          temp_output_file = Tempfile.new(["#{name.parameterize}", ".webp"])
          begin
            image.format("webp") { |cmd| cmd.auto_orient }
            image.write(temp_output_file.path)
            product.image.attach(io: File.open(temp_output_file.path), filename: "#{name.parameterize}.webp", content_type: "image/webp")
          rescue MiniMagick::Error
          ensure
            temp_output_file.close
            temp_output_file.unlink
          end
        end
        temp_input_file.close
        temp_input_file.unlink
      end
      puts "#{category.name} added, #{name}"
    end

    sleep(2.5)
  end
end


def fetch_and_create_products_from_tcgdex(set_id, category_type)
  category = Category.find_or_create_by(name: category_type)

  set_url = "https://api.tcgdex.net/v2/en/sets/#{set_id}"
  set_response = HTTParty.get(set_url)
  set_data = set_response.parsed_response

  card_ids = set_data['cards'].map { |card| card['id'] }.first(50)

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

    if image_url.present?
      image_file = OpenURI.open_uri(webp_image_url)
      product.image.attach(io:image_file, filename: "#{name.parameterize}.webp")
    end

    puts "card added: #{name}"
    sleep(0.3)
  end
end

hot_board_games_url = "https://boardgamegeek.com/xmlapi2/hot?type=boardgame"
category_type = "Board Game"
fetch_and_create_products_from_bgg(hot_board_games_url, category_type)

hot_rpg_url = "https://boardgamegeek.com/xmlapi2/hot?type=rpg"
category_type = "Role Playing Game"
fetch_and_create_products_from_bgg(hot_rpg_url, category_type)

hot_rpg_url = "https://boardgamegeek.com/xmlapi2/hot?type=videogame"
category_type = "Video Game"
fetch_and_create_products_from_bgg(hot_rpg_url, category_type)

set_id = "base1"
category_type = "Pokemon Card"
fetch_and_create_products_from_tcgdex(set_id, category_type)

if Rails.env.development?
  AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
    admin.password = 'password'
    admin.password_confirmation = 'password'
  end
end