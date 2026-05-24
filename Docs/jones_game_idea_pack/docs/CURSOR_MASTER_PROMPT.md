# Cursor Master Prompt

Project: Jones In The Lane

Working repo:
C:\Users\yaniv\source\repos\Jones In The Lane\repo_base

Goal:
Continue development of Jones as a web-based 2D life simulation game.

Current direction:
- React + TypeScript + Vite frontend
- Firebase Hosting
- Firestore database
- Firebase Functions backend
- Canvas 2D map renderer
- GameEngine simulation loop
- WorldState with player, NPCs, zones
- zone interaction layer

Rules:
- Do not simplify architecture
- Do not remove modules
- Do not hardcode Firebase config
- Keep renderer read-only
- Keep GameEngine independent from renderer
- Keep feature modules modular
- Keep Firebase config via VITE_FIREBASE_* env vars

Next milestone:
Turn the prototype into a real playable vertical slice.

Tasks:
1. Verify app can run locally with npm install and npm run dev.
2. Verify GameEngine starts from App.tsx.
3. Verify Canvas renderer displays map/player/NPCs.
4. Verify movement works with WASD and arrow keys.
5. Verify zone interaction panel changes by player location.
6. Add real panels for:
   - Bank
   - Inventory
   - Jobs
   - Education
7. Connect local actionDispatcher to existing feature modules first.
8. Only then connect selected actions to Firebase callables.
9. Update docs after every milestone.
10. Keep changes minimal and production-oriented.

Return:
- files changed
- exact commands run
- build result
- next recommended step
