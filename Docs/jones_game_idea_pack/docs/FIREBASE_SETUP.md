# Firebase Setup

## Firebase Project
Display name:
Jones In The Lane

Project ID:
jones-in-the-lane

Region:
europe-west1

Web app nickname:
Jones Web

## Env File
Create .env in the repo root:

VITE_FIREBASE_API_KEY=AIzaSyBqHNxhE-RFnvxlb9SeHU0Jt5UtB76dZNo
VITE_FIREBASE_AUTH_DOMAIN=jones-in-the-lane.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=jones-in-the-lane
VITE_FIREBASE_STORAGE_BUCKET=jones-in-the-lane.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=305546124043
VITE_FIREBASE_APP_ID=1:305546124043:web:d16c664465402c301fa00e
VITE_FIREBASE_MEASUREMENT_ID=G-D5KX3FFYL4

## Hosting
Use Firebase Hosting with:

public/build output: dist
SPA rewrite: /index.html

## Expected Files
- firebase.json
- .firebaserc
- firestore.rules
- firestore.indexes.json
- storage.rules
- functions/package.json

## Deploy Flow
npm run build
firebase deploy --only hosting

Later:
firebase deploy --only functions,firestore,storage,hosting
