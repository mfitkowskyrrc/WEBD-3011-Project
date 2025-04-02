require 'httparty'
require 'nokogiri'

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
      description = item.xpath('description').text.strip

      Product.create!(
        name: name,
        description: description,
        category_id: category.id,
        price: Faker::Number.decimal(l_digits: 2, r_digits: 3)
      )
      puts "#{category.name} added, #{name}"
    end

    sleep(2)
  end
end


def fetch_and_create_products_from_tcgdex(set_id, category_type)
  category = Category.find_or_create_by(name: category_type)

  set_url = "https://api.tcgdex.net/v2/en/sets/#{set_id}"
  set_response = HTTParty.get(set_url)
  set_data = set_response.parsed_response

  card_ids = set_data['cards'].map { |card| card['id'] }.first(10)

  card_ids.each do |card_id|
    card_url = "https://api.tcgdex.net/v2/en/cards/#{card_id}"
    card_response = HTTParty.get(card_url)
    card_data = card_response.parsed_response

    name = card_data['name']
    set_name = card_data['set']['name']
    local_id = card_data['localId']
    description = card_data['text'] || "This card is card number #{local_id} of the #{set_name} set."

    Product.create!(
      name: name,
      description: description,
      category_id: category.id,
      price: Faker::Number.decimal(l_digits: 2, r_digits: 3)
    )
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

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?