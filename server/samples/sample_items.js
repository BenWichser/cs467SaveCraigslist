/* Sample Items for SaveCraigsList */

const sampleItemA = {
    id: 'sampleItemA',
    date_added: '1415577600000',
    title: 'Travel Mug',
    description: 'Light blue Starbucks travel mug, with straw.  Straw slightely gnawed on by small child. Paint is peeling on bottom edge, leaving a vintage patina.',
    seller_id: 'art',
    price: '25.75',
    location: '08014',
    status: 'For Sale',
    photos: [
        {
            'M':{
                caption: 
                {'S' : "Front of mug"}, 
                URL: 
                {'S' : "mug_front.jpeg"}
            }
        },
        /*
         {
            caption: "Side of mug", 
            URL: "mug_side.png"
        },
        {
            caption: "Top of mug", 
            URL: "mug_top.jpeg"
        },
        {
            caption: 
            "Bottom of mug.  Note patina and Starbucks seal of authenticity",
            URL: "mug_bottom.png"
        }
        */
    ],
    tags: [
        {'S': 'blue'}, 
        {'S': 'mug'},
        {'S': 'starbucks'}
    ]
}

const sampleItemB = {
    id: 'sampleItemB',
    date_added: '1621296000000',
    title: 'Altoids Tin',
    description: 'Used tin of Altoids.  Certified to be dent-free.  Any residual powder is from mints, though this is not guaranteed.',
    seller_id: 'jbutt',
    price: '0.25',
    location: '70116',
    status: 'For Sale',
    photos: [],
    tags: [
        {'S': 'metal'}, 
        {'S': 'tin'}, 
        {'S': 'mint'},
        {'S': 'powder'}
    ]
}

const sampleItemC = {
    id: 'sampleItemC',
    date_added: '1626220800000',
    title: 'Molding Danish',
    description: 'Cheese Danish from Costco.  Was fresh when purchased.  This piece of Art art represents our muddled values: expiring food from a big box store, albeit a store that pays its employees well but also serves cheap hot dogs.',
    seller_id: 'art',
    price: '4',
    location: '08014',
    status: 'Pending',
    photos: [
        {
            M:
            {
                caption: 
                { 'S' :"Note asymmetric cheese crack from baking.  Important: only one Danish will be sent.  I already at the other one"}, 
                URL: 
                { 'S' : "danish_art.jpeg"}
            }
        }
    ],
    tags: [
        {"S": 'danish'},
        {"S": 'food'},
        {"S": 'cheese'}
    ]
};

const sampleItemD = {
    id: 'sampleItemD',
    date_added: '1609891200000',
    title: 'Over Glasses Sunglasses',
    description: 'Be the coolest person on the block with these fly shades.  Made to fit over your other glasses, these provide eye protection and looks all at once!',
    seller_id: 'joebiden46',
    price: '15.25',
    location: '20500',
    status: 'Sold',
    photos: [
        {
            M:
            {
                caption: 
                {'S': "Small smudge on right lense should come out with careful cleaning."}, 
                URL:
                {'S': "frontview.png"}
            }
        }, 
        /*
         {
            caption: "Side lense provided for extra visibility and flash!",
            URL: "sideview.jpeg"
        }
        */
    ],
    tags: [
        {'S': 'over'},
        {'S': 'glasses'},
        {'S': 'sunglasses'}
    ]
};

const sampleItemE = {
    // item that is 1 mile from jbutt
    id: 'sampleItemE',
    date_added: '1627534156871',
    title: 'Neighbor Item',
    description: 'Item for sale from your nearest neighbor',
    seller_id: 'neighborSeller',
    price: '0.25',
    location: '70146',
    status: 'For Sale',
    photos: [
    ],
    tags: [
        {'S': 'neighbor'},
        {'S': 'item'}
    ]
};

const sampleItemF = {
    // item that is 2 miles from jbutt
    id: 'sampleItemF',
    date_added: '1627534734106',
    title: 'Very Close Item',
    description: 'Item for sale from a very close neighbor',
    seller_id: 'veryCloseSeller',
    price: '0.50',
    location: '70113',
    status: 'For Sale',
    photos: [],
    tags: [
        {'S': 'close'},
        {'S': 'item'}
    ]
};

const sampleItemG = {
    // item that is 7 miles from jbutt
    id: 'sampleItemG',
    date_added: '1627535147765',
    title: 'Close Item',
    description: 'Item for sale from a close neighbor',
    seller_id: 'closeSeller',
    price: '1',
    location: '70002',
    status: 'For Sale',
    photos: [],
    tags: [
        { 'S': 'close'},
        { 'S': 'item'}
    ]
};

const sampleItemH = {
    // item that is 14 miles from jbutt
    id: 'sampleItemH',
    date_added: '1627535743914',
    title: 'Nearby Item',
    description: 'Item that isn\'t quite close, but is nearby',
    seller_id: 'nearbySeller',
    price: '20',
    location: '70031',
    status: 'For Sale',
    photos: [],
    tags: [
        {'S': 'nearby'},
        {'S': 'item'}
    ]
};

const sampleItemI = {
    // item that is 45 miles from jbutt
    id: 'sampleItemI',
    date_added: '1627536987393',
    title: 'Not Far Item',
    description: 'It is a bit of a drive, but this item isn\'t too far',
    seller_id: 'notFarSeller',
    price: '50',
    location: '39466',
    status: 'For Sale',
    photos: [],
    tags: [
        {'S': 'far'},
        {'S': 'item'}
    ]
};

const sampleItemJ = {
    // item that is 95 miles from jbutt
    id: 'sampleItemJ',
    date_added: '1627537258098',
    title: 'Far Item',
    description: 'This item is far from you. Day trip?',
    seller_id: 'farSeller',
    price: '100',
    location: '39404',
    status: 'For Sale',
    photos: [],
    tags: [
        {'S': 'far'},
        {'S': 'item'}
    ]
};

const sampleItemK = {
    // item that is 1169 miles from jbutt
    id: 'sampleItemK',
    date_added: '1627539165241',
    title: 'Very Far Item',
    description: 'This item is very far from you.',
    seller_id: 'veryFarSeller',
    location: '10001',
    status: 'For Sale',
    price: '25',
    photos: [],
    tags: [
        { 'S': 'far' },
        { 'S': 'item'}
    ]
}

const sampleItems = [
    sampleItemA,
    sampleItemB,
    sampleItemC,
    sampleItemD,
    sampleItemE,
    sampleItemF,
    sampleItemG,
    sampleItemH,
    sampleItemI,
    sampleItemJ,
    sampleItemK
]
module.exports = {sampleItems};
