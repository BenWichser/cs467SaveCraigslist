/* Sample Users for SaveCraigsList */

const sampleUserA = {
    id: "jbutt",
    email: "jbutt@gmail.com",
    password: "password",
    zip: "70116",
    recents: [],
    photo: 'jamesbutt.jpg', // Not standard.  Sample users only
};

const sampleUserB = {
    id: "josephine_darakjy",
    email: "josephine_darakjy@darakjy.org",
    password: "password1",
    zip: "48116",
    recents: [],
    photo: 'josephine_darakjy.jpg', // Not standard.  Sample users only
};

const sampleUserC = {
    id: "art",
    email: "art@venere.org",
    password: "password1!",
    zip: "08014",
    recents: [],
    photo: 'art.jpg', // Not standard.  Sample users only
};

const sampleUsers = [sampleUserA, sampleUserB, sampleUserC];
module.exports = {sampleUsers};
