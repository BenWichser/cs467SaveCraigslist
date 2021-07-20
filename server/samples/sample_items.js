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
        {'S': 'danish'},
        {'S': 'food'},
        {'S': 'cheese'}
    ]
};


const sampleItems = [
    sampleItemA,
    sampleItemB,
    sampleItemC,
    sampleItemD
]
module.exports = {sampleItems};
