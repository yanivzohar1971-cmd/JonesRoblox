# Architecture

## Frontend
React + TypeScript + Vite.

Main folders:

- src/app
- src/features
- src/graphics
- src/types
- src/lib/firebase.ts

## Backend
Firebase Cloud Functions.

Main folders:

- functions/src/callable
- functions/src/util
- functions/src/index.ts

## Database
Firestore.

Suggested collections:

- players
- worlds
- cities
- npcProfiles
- economy
- businesses
- jobs
- housing
- inventory
- messages
- events

## Hosting
Firebase Hosting.

Vite build output:

- dist

SPA rewrite:

- all routes → /index.html

## Runtime Layers

React UI
↓
GameEngine
↓
WorldState / Feature Modules
↓
Firebase Functions
↓
Firestore

Parallel graphics layer:

GameEngine / WorldState
↓
Canvas Renderer
↓
Map + player + NPCs
