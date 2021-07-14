const userTemplate = {
    'id': 'S',
    'email': 'S',
    'password': 'S',
    bucket: 'S',
    photo: 'S',
    'zip': 'S',
    rating_buyer: 'N',
    rating_seller: 'N',
    items_bought: 'L',
    current_listings: 'L',
    past_listings: 'L',
    recent_searches: 'L'
}

const itemTemplate = {
    id: 'S',
    title: 'S',
    description: 'S',
    seller_id: 'S',
    price: 'N',
    "location": 'S',
    "status": 'S',
    photos: 'L',
    tags: 'L'
}

const messageTemplate = {
    'sender_id': 'S',
    'receiver_id': 'S',
    'date_sent': 'S',
    'content': 'S'
}

module.exports = {userTemplate, itemTemplate, messageTemplate};
