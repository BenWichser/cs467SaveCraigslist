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

const sampleUsers = [sampleUserA, sampleUserB, sampleUserC];
module.exports = {sampleUsers};
