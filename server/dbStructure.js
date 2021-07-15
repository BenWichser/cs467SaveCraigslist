const userTemplate = {
    'id': 'S',
    'email': 'S',
    'password': 'S',
    'photo': 'S',
    'zip': 'S',
    'rating_buyer': 'N',
    'rating_seller': 'N',
    'items_bought': 'L',        // [ {'S': id }, ]
    'current_listings': 'L',    // [ {'S': id }, ]
    'past_listings': 'L',       // [ {'S': id }, ]
    'recent_searches': 'L'      // [ {'M': {'search': 'S', 'most_recent_search': S}}, ]
}

const itemTemplate = {
    'id': 'S',
    'date_added': 'S',
    'title': 'S',
    'description': 'S',
    'seller_id': 'S',
    'price': 'N',
    'location': 'S',
    'status': 'S',
    'photos': 'L',              // [ {'M': {'caption': 'S', 'URL': 'S'}}, ]
    'tags': 'L'                 // [ {'S': #tag} , ]
}

const messageTemplate = {
    'id': 'S',
    'sender_id': 'S',
    'receiver_id': 'S',
    'date_sent': 'S',
    'content': 'S'
}

module.exports = {userTemplate, itemTemplate, messageTemplate};
