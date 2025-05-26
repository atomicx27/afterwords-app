# AfterWords - Legacy Messaging App

AfterWords is a Flutter-based legacy messaging app that allows users to prepare messages—text, audio, video, or photos—for loved ones. These messages are delivered after the user's death, based on inactivity, using a dead man's switch concept.

## 🎯 Purpose

AfterWords helps users create meaningful messages for their loved ones that will be delivered when they're no longer able to do so themselves. The app uses a check-in system to determine when messages should be sent.

## 🔑 Key Features

### 1. Message Creation
- ✍️ Text messages
- 🎥 Videos
- 🎙️ Voice notes
- 🖼️ Photos
- Assign different recipients and customize delivery

### 2. Dead Man's Switch System
- Users set a check-in interval (daily/weekly/etc.)
- At each interval, the user must confirm they're alive by entering a password
- If they don't check in before the interval ends, the app assumes the user is deceased and automatically sends the scheduled messages

### 3. Message Delivery
- 📧 Email (SMTP or API like Resend/Postmark via Supabase Edge Functions)
- 📱 WhatsApp (via external integration or webhook automation)
- Potential future support: SMS, Telegram, in-app notifications

### 4. Recipient Management
- Add/remove/edit recipients
- Assign individual messages or batch messages
- Schedule time-delayed or conditional delivery

## 🛠️ Tech Stack

### Frontend: Flutter
- Cross-platform UI
- Authentication flow, media handling, check-in prompts
- Integration with Supabase via REST or RPC

### Backend: Supabase
1. **Supabase Auth**: Secure login (email/password, OTP, or social)
2. **PostgreSQL**: Structured tables for users, messages, recipients, check_in_logs, message_status
3. **Supabase Storage**: For media files (audio, video, photos)
4. **Supabase Edge Functions**: Dead man's switch logic and message dispatch
5. **Real-time & Triggers**: Realtime DB triggers and notifications

## 🏗️ Project Structure

```
lib/
├── config/
│   └── supabase_config.dart      # Supabase configuration
├── models/
│   ├── user_model.dart           # User data model
│   ├── message_model.dart        # Message data model
│   ├── recipient_model.dart      # Recipient data model
│   └── check_in_log_model.dart   # Check-in log model
├── services/
│   ├── auth_service.dart         # Authentication service
│   ├── message_service.dart      # Message management
│   ├── recipient_service.dart    # Recipient management
│   ├── dead_mans_switch_service.dart # Dead man's switch logic
│   └── notification_service.dart # Local notifications
├── providers/
│   ├── auth_provider.dart        # Authentication state
│   ├── message_provider.dart     # Message state
│   └── recipient_provider.dart   # Recipient state
├── screens/
│   ├── splash_screen.dart        # App splash screen
│   ├── auth/                     # Authentication screens
│   ├── home/                     # Home dashboard
│   ├── messages/                 # Message management
│   ├── recipients/               # Recipient management
│   ├── settings/                 # App settings
│   └── check_in/                 # Check-in screen
├── widgets/                      # Reusable UI components
└── main.dart                     # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.24.5 or later)
- Android Studio (for Android development)
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd afterwords-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Update `lib/config/supabase_config.dart` with your Supabase credentials
   - Set up the database schema (see Database Setup section)

4. **Run the app**
   ```bash
   flutter run
   ```

## 🗄️ Database Setup

The app requires the following Supabase tables:

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  check_in_interval_hours INTEGER DEFAULT 168, -- 7 days
  last_check_in TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Messages Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  type TEXT NOT NULL CHECK (type IN ('text', 'audio', 'video', 'image')),
  file_path TEXT,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'sent', 'failed')),
  recipient_ids UUID[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Recipients Table
```sql
CREATE TABLE recipients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  relationship TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Check-in Logs Table
```sql
CREATE TABLE check_in_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  check_in_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ip_address TEXT,
  user_agent TEXT
);
```

## 🔐 Security & Privacy

- Row-level security (RLS) policies ensure users only access their own data
- Encrypted media files in Supabase Storage
- Optional encryption for sensitive text messages
- Secure authentication with Supabase Auth

## 📱 Current Implementation Status

### ✅ Completed
- Flutter project setup with comprehensive dependencies
- Complete app architecture and folder structure
- Core data models (User, Message, Recipient, CheckInLog)
- Comprehensive services (Auth, Message, Recipient, DeadMansSwitch, Notification)
- State management with Provider pattern
- Supabase configuration and integration
- Basic UI screens (Splash, Login, Register, Home, Settings, Check-in)
- Navigation with GoRouter
- Authentication flow

### 🚧 In Progress / TODO
- Complete message creation and editing UI
- Media file handling (audio, video, image recording/selection)
- Recipient management UI
- Settings screens (check-in interval, notifications, security)
- Dead man's switch background processing
- Message delivery system via Supabase Edge Functions
- Push notifications
- Biometric authentication
- Data encryption
- Testing and debugging

## 🧪 Testing

To run tests:
```bash
flutter test
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support or questions, please open an issue in the repository.
