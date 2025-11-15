# 🏃‍♂️ Racing Run

> **A super cool racing game where YOU are the character!**

Built with love by a dad and his awesome 5-year-old son. 🎮👨‍👦

---

## 🌟 What Makes This Game Special?

In Racing Run, you don't just *play* a character - **you ARE the character!**

Take a picture of yourself, and watch as your face magically appears on your racing character. Then get ready to run, jump, and race your way to victory!

### ✨ Current Features

- 📸 **Face Photo Capture** - Use your device's camera to take a selfie
- 🎭 **Automatic Face Detection** - Advanced AI detects and crops your face perfectly
- 🏃 **Animated Character** - Your face sits on top of a running, jumping game character
- 💾 **Saved Progress** - Your character is saved so you can play again and again
- 🎨 **Kid-Designed Gameplay** - Game mechanics designed by a creative 5-year-old!
- ☁️ **Cloud Sync** - Save your characters to the cloud and access them anywhere
- 🏆 **Global Leaderboard** - Compete with players around the world
- 👤 **User Accounts** - Register and track your progress across devices
- 🎯 **Score Tracking** - Submit your scores and see your rank

### 🚀 Coming Soon

This game is being actively developed! Here's what we're dreaming up:

- 🏁 Racing tracks and obstacles
- ⚡ Power-ups and special abilities
- 🎵 Fun sound effects and music
- 🏅 Daily challenges and rewards
- 🎨 Downloadable costumes and character customization
- 🤝 Multiplayer racing challenges
- 📊 Detailed player statistics

---

## 🛠 Technical Details

Racing Run is built using:

### iOS App
- **Swift** - Apple's modern programming language
- **SpriteKit** - Apple's 2D game engine
- **Vision Framework** - For advanced face detection
- **AVFoundation** - For camera capture

### Backend API
- **Next.js** - Modern web framework deployed on Vercel
- **TypeScript** - Type-safe backend code
- **Vercel Postgres** - Scalable cloud database
- **Vercel Blob** - Cloud storage for character images
- **JWT Authentication** - Secure user sessions

### Key Components

#### 📷 CharacterCreationViewController
The magic starts here! This view controller:
- Manages the camera interface
- Captures your photo
- Uses Vision framework to detect faces
- Crops and processes the face image
- Saves it for use in the game

#### 🎮 PlayerCharacter
Your in-game avatar! This SpriteKit node:
- Combines your face photo with an animated body
- Handles running and jumping animations
- Manages physics for realistic movement
- Can be easily customized with new animations

#### 💾 CharacterImageManager
The memory keeper! This manager:
- Saves your face image locally
- Loads it when needed
- Ensures persistence across app launches
- Handles image data efficiently

---

## 🎯 The Vision

Racing Run is more than just a game - it's a **learning adventure** for a young game designer and his dad. Every feature, every mechanic, every wild idea comes from the imagination of a 5-year-old who loves games.

This project demonstrates:
- 🧠 **Real-world iOS development** with modern Swift
- 🎨 **Computer Vision** applied to game design
- 🎮 **Game development** using SpriteKit
- 👨‍👦 **Parent-child collaboration** on creative projects
- 🌱 **Learning by building** something fun and tangible

---

## 🏗 Development Setup

### Requirements
- Xcode 14.0 or later
- iOS 15.0 or later
- A device with a camera (for character creation)

### Getting Started

1. Clone this repository
   ```bash
   git clone https://github.com/[username]/racing-run.git
   ```

2. Open `Racing Run.xcodeproj` in Xcode

3. Select a target device or simulator

4. Build and run! (⌘R)

5. Take your selfie and start racing!

### Important Notes

- The app requires **camera permissions** to create your character
- Face detection works best with:
  - Good lighting
  - Face directly facing the camera
  - Clear, unobstructed view of your face
- Your photo can be stored **locally only** (offline mode) or synced to the cloud (online mode)

### Backend Setup (Optional - for Cloud Features)

To enable cloud features like leaderboards and character sync:

1. Deploy the backend to Vercel:
   ```bash
   cd backend
   npm install
   vercel --prod
   ```

2. Configure the iOS app with your API URL (see [DEPLOYMENT.md](DEPLOYMENT.md) for details)

3. Or skip authentication and play offline with local-only character storage

See the complete deployment guide in [DEPLOYMENT.md](DEPLOYMENT.md).

---

## 🎨 For Young Developers

If you're a kid (or kid at heart) who wants to make games, here's what this project can teach you:

1. **You can make games!** - Age doesn't matter when you have ideas
2. **Your ideas are valuable** - Every feature here came from real excitement and imagination
3. **Building is learning** - The best way to learn is to create
4. **Games are code** - And code is just instructions, like a recipe

---

## 🤝 Contributing

This is primarily a learning project for a father-son team, but we love seeing what others create!

If you have ideas or find issues:
- Open an issue to share ideas
- Fork and experiment
- Share what you build!

---

## 📜 License

This project is open source and available for learning and fun. Feel free to use it as inspiration for your own projects!

---

## 💝 Special Thanks

To my incredible 5-year-old son - the real creative director of this project. Your imagination makes this fun, your excitement keeps us going, and your ideas make this game unique.

Never stop creating! 🌟

---

**Built with Swift, SpriteKit, and lots of giggles** 🎮✨

*This README was crafted with pride to showcase our journey of building a game together.*
