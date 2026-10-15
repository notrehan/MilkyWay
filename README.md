
# MilkyWay 🌌

## Explore new worlds, meet cosmic matches, and discover where you belong.

### Team Name: [Your Team Name]

### Team Members
- Member 1: [Your Name] - [Your Institution]
- Member 2: [Member Name] - [Institution]

### Hosted Project Link
[Add hosted project link, if available]

### Project Description
MilkyWay is an intergalactic discovery and dating app built using Flutter and Supabase. Users can explore fictional planets, discover alien profiles, and create their own human profile with personal details and survival preferences. The app combines a playful space theme with swipe-based discovery and a clean, minimal interface.

### The Problem statement
Traditional dating and discovery apps focus on connections within our own world. There is no fun, interactive way to imagine exploring other planets and meeting life forms from across the galaxy.

### The Solution
MilkyWay offers a unique intergalactic experience where users can explore planets, discover alien profiles, and create their own profiles. With swipe-based interactions and a Supabase backend, the app brings planetary exploration and cosmic matchmaking together.

---

## Technical Details

### Technologies/Components Used

**For Software:**
- Languages used: Dart, SQL
- Frameworks used: Flutter
- Libraries used: `supabase_flutter`, `image_picker`, `flutter_dotenv`
- Backend and database: Supabase
- Tools used: VS Code, Git, Flutter SDK, Xcode Simulator, Supabase Dashboard

---

## Features

- **User Authentication:** Sign up, log in, and log out using Supabase Authentication.
- **Human Profiles:** Create a personal profile with a name, bio, preferences, and profile photo.
- **Photo Uploads:** Upload profile photos to Supabase Storage.
- **Planet Discovery:** Explore planets and view their descriptions, climate, atmosphere, gravity, habitability, pros, and cons.
- **Swipe-Based Exploration:** Like or pass on planets using swipe gestures or action buttons.
- **Alien Discovery:** Browse alien profiles containing their names, species, home planets, bios, and photos.
- **Alien Matching:** Like or pass on alien profiles and view liked profiles during the current session.
- **Navigation:** Easily switch between Home, Planets, Aliens, and Profile sections.
- **Minimal UI:** A light theme with pastel cards and a clean, space-inspired design.

---

## Project Documentation

### For Software:

#### Screenshots (Add at least 3)

Add screenshots of the running application to your repository.

**1. Home Screen**

<img src="./screenshots/home.png" alt="MilkyWay Home Screen" width="300">

**2. Planet Discovery Screen**

<img src="./screenshots/planets.png" alt="MilkyWay Planet Discovery" width="300">

**3. Alien Discovery Screen**

<img src="./screenshots/aliens.png" alt="MilkyWay Alien Discovery" width="300">

#### Architecture Diagram

```text
             Flutter Mobile App
                     |
                     v
              Supabase Client
                     |
          +----------+----------+
          |          |          |
          v          v          v
     Supabase     PostgreSQL   Supabase
       Auth       Database     Storage
                     |             |
              +------+------+   Profile
              |      |      |    Photos
           Human   Alien  Planet
          Profiles Profiles Data
```

### Setup and Run

1. Install Flutter and the required platform tools.
2. Clone the repository and open the project folder.
3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Create a `.env` file in the project root:

   ```env
   SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
   SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
   ```

5. Configure the required Supabase database tables, Row Level Security policies, and the `profile-photos` Storage bucket.
6. Run the application:

   ```bash
   flutter run
   ```

**Security Note:** Use only the Supabase publishable/anon key in the Flutter application. Never expose your Supabase service-role key or commit real credentials to Git.

### Current Limitations

- Planet and alien likes/passes are stored locally in application memory and may reset when the app restarts.
- A hosted project link and actual screenshots should be added before final submission.
- The banner and screenshot paths must match the image files in the repository.
