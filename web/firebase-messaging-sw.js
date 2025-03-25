// this file is for web Permissions Web requires a Firebase service worker

importScripts("https://www.gstatic.com/firebasejs/10.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
 
  apiKey: 'AIzaSyBK29YPrJznbUwQd4xTdHijABtf-uc5he4',
  appId: '1:473618040953:web:c87bafd4d0204450f26ca8',
  messagingSenderId: '473618040953',
  projectId: 'babyshophub-55389',
  authDomain: 'babyshophub-55389.firebaseapp.com',
  storageBucket: 'babyshophub-55389.firebasestorage.app',
  measurementId: 'G-DM5X8JP72W',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log("📩 Received background message ", payload);
});
