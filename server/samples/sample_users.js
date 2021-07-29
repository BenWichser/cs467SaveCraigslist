/* Sample Users for SaveCraigsList */

const userTemplate = {
    'id': 'S',
    'email': 'S',
    'password': 'S',
    'zip': 'S',
    'recents': [
        { 'recent_id': 'S', 'message_id': 'S'} , 
    ],
    'photo': 'S',            // Not standard.  Sample users only
}

const sampleUserA = {
    id: "jbutt",
    email: "jbutt@gmail.com",
    password: "password",
    zip: "70116",
    recents: [
        { recent_id: 'art', message_id: 'sampleMessageG'},
        { recent_id: 'joebiden46', message_id: 'sampleMessageB'}
    ],
    photo: 'jamesbutt.jpg', // Not standard.  Sample users only
};

const sampleUserB = {
    id: "josephine_darakjy",
    email: "josephine_darakjy@darakjy.org",
    password: "password1",
    zip: "48116",
    recents: [
        {recent_id: 'art', message_id: 'sampleMessageF'}
    ],
    photo: 'josephine_darakjy.jpg', // Not standard.  Sample users only
};

const sampleUserC = {
    id: "art",
    email: "art@venere.org",
    password: "password1!",
    zip: "08014",
    recents: [
        {recent_id: 'jbutt', message_id: 'sampleMessageG'},
        {recent_id: 'josephine_darakjy', message_id: 'sampleMessageF'},
    ],
    photo: 'art.jpg', // Not standard.  Sample users only
};

const sampleUserD = {
    // made to be 1 mile from jbutt
    id: 'neighborSeller',
    email: 'neighborSeller@gmail.com',
    password: 'password',
    zip: '70146',
    recents: [],
    photo: 'neighborSeller.jpg',
};

const sampleUserE = {
    // made to be 2 miles from jbutt
    id: 'veryCloseSeller',
    email: 'veryCloseSeller@gmail.com',
    password: 'password',
    zip: '70113',
    recents: [],
    photo: 'veryCloseSeller.jpg'
};

const sampleUserF = {
    // made to be 7 miles from jbutt
    id: 'closeSeller',
    email: 'closeSeller@gmail.com',
    password: 'password',
    zip: '70002',
    recents: [],
    photo: 'closeSeller.jpg'
};

const sampleUserG = {
    // made to be 14 miles from jbutt
    id: 'nearbySeller',
    email: 'nearbySeller@gmail.com',
    password: 'password',
    zip: '70031',
    recents: [],
    photo: 'nearbySeller.jpg'
};

const sampleUserH = {
    // made to be 45 miles from jbutt
    id: 'notFarSeller',
    email: 'notFarSeller@gmail.com',
    password: 'password',
    zip: '39466',
    recents: [],
    photo: 'notFarSeller.jpg'
};

const sampleUserI = {
    // made to be 95 miles from jbutt
    id: 'farSeller',
    email: 'farSeller@gmail.com',
    password: 'password',
    zip: '39404',
    recents: [],
    photo: 'farSeller.jpg'
}

const sampleUserJ = {
    // made to be 1169 miles from jbutt
    id: 'veryFarSeller',
    email: 'very/FarSeller@gmail.com.',
    password: 'password',
    zip: '10001',
    recents: [],
    photo: 'veryFarSeller.jpg'
};


const sampleUsers = [
    sampleUserA, 
    sampleUserB, 
    sampleUserC, 
    sampleUserD, 
    sampleUserE, 
    sampleUserF,
    sampleUserG,
    sampleUserH,
    sampleUserI,
    sampleUserJ
];

module.exports = {sampleUsers};
