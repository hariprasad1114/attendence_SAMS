# Smart Attendance Management System (SAMS)

A comprehensive Flutter mobile application with PHP backend for automated attendance tracking in educational institutions.

## 🌟 Features

### Multi-Role System
- **Students**: Mark attendance using codes, view attendance history and statistics
- **Teachers**: Generate attendance codes, monitor student attendance, manage classes
- **Admins**: Manage users, view system reports, oversee all operations
- **Counselors**: Monitor low attendance students, generate analytics reports

### Key Functionalities
- ✅ Role-based authentication and authorization
- ✅ Real-time attendance code generation and validation
- ✅ Beautiful animated UI with modern design
- ✅ Comprehensive reporting and analytics
- ✅ User management system
- ✅ RESTful API backend
- ✅ MySQL database with optimized schema

## 🛠️ Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Navigation**: Go Router
- **Animations**: Flutter Animate, Lottie
- **HTTP Client**: Dio
- **UI Components**: Material Design 3
- **Charts**: FL Chart

### Backend (PHP)
- **Language**: PHP 8.0+
- **Database**: MySQL 8.0+
- **Server**: Apache (XAMPP)
- **API**: RESTful JSON APIs
- **Security**: Password hashing, input sanitization

## 📱 App Architecture

```
lib/
├── main.dart
├── screens/
│   ├── login/
│   │   └── login_screen.dart
│   ├── dashboards/
│   │   ├── student_dashboard.dart
│   │   ├── teacher_dashboard.dart
│   │   ├── admin_dashboard.dart
│   │   └── counselor_dashboard.dart
│   ├── attendance/
│   │   ├── student_attendance_page.dart
│   │   ├── teacher_generate_code.dart
│   │   └── attendance_history.dart
│   └── management/
│       ├── add_student_page.dart
│       ├── view_students_page.dart
│       └── reports_page.dart
├── widgets/
│   ├── custom_button.dart
│   ├── animated_header.dart
│   └── input_field.dart
├── theme/
│   ├── app_colors.dart
│   └── app_theme.dart
├── models/
│   ├── user.dart
│   └── attendance.dart
├── services/
│   ├── auth_service.dart
│   └── api_service.dart
└── utils/
    └── app_router.dart
```

## 🗄️ Database Schema

### Core Tables
- **users**: User accounts (students, teachers, admins, counselors)
- **attendance_codes**: Teacher-generated attendance codes
- **attendance**: Attendance records
- **subjects**: Available subjects
- **departments**: Academic departments
- **notifications**: System notifications
- **system_settings**: Configuration settings

### Key Features
- Optimized indexes for performance
- Foreign key constraints for data integrity
- Triggers for automated updates
- Views for complex queries
- Stored procedures for reports

## 🚀 Setup Instructions

### Prerequisites
1. **Flutter SDK** (3.0 or higher)
2. **XAMPP** (Apache + MySQL)
3. **VS Code** or **Android Studio**
4. **Git**

### Backend Setup (XAMPP)

1. **Install XAMPP**
   ```bash
   # Download from https://www.apachefriends.org/
   # Install and start Apache + MySQL services
   ```

2. **Setup Database**
   ```bash
   # Open phpMyAdmin (http://localhost/phpmyadmin)
   # Import the database schema
   # File: database/sams_schema.sql
   ```

3. **Configure API**
   ```bash
   # Copy backend_api folder to XAMPP htdocs
   cp -r backend_api/ C:/xampp/htdocs/
   
   # Test API endpoint
   curl http://localhost/backend_api/login.php
   ```

4. **Database Configuration**
   ```php
   // Edit backend_api/db_connect.php
   $host = 'localhost';
   $dbname = 'attendance_system';
   $username = 'root';
   $password = ''; // Default XAMPP password
   ```

### Frontend Setup (Flutter)

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd sams_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL**
   ```dart
   // Edit lib/services/api_service.dart
   static const String baseUrl = 'http://localhost/backend_api';
   ```

4. **Run Application**
   ```bash
   flutter run
   ```

## 📋 Default Credentials

### Admin Account
- **Email**: admin@sams.com
- **Password**: password
- **Role**: Admin

### Test Accounts (Create via Admin Panel)
- **Student**: student@example.com
- **Teacher**: teacher@example.com
- **Counselor**: counselor@example.com

## 🔧 API Endpoints

### Authentication
- `POST /login.php` - User login
- `POST /register_user.php` - User registration

### Attendance Management
- `POST /generate_code.php` - Generate attendance code
- `POST /validate_code.php` - Validate attendance code
- `POST /mark_attendance.php` - Mark student attendance
- `GET /get_attendance.php` - Get attendance records

### User Management
- `GET /get_users.php` - Get all users
- `GET /get_low_attendance_students.php` - Get low attendance students

### Reports
- `GET /reports.php` - Generate various reports

## 🎨 UI/UX Features

### Design Elements
- **Modern Material Design 3** interface
- **Gradient backgrounds** with role-specific colors
- **Smooth animations** using Flutter Animate
- **Responsive design** for different screen sizes
- **Dark/Light theme** support
- **Custom widgets** for consistent UI

### Role-Specific Colors
- **Student**: Blue gradient
- **Teacher**: Green gradient
- **Admin**: Red gradient
- **Counselor**: Purple gradient

### Animations
- **Page transitions** with slide and fade effects
- **Button interactions** with shimmer effects
- **Loading states** with progress indicators
- **Success/Error feedback** with animated icons

## 📊 Features by Role

### Student Dashboard
- View attendance percentage and statistics
- Mark attendance using teacher codes
- View attendance history with filters
- Profile management

### Teacher Dashboard
- Generate attendance codes for classes
- Monitor student attendance in real-time
- View class-wise attendance reports
- Manage student lists

### Admin Dashboard
- Add/edit/delete users
- View system-wide reports
- Monitor all attendance data
- System configuration

### Counselor Dashboard
- Identify students with low attendance
- Generate attendance analytics
- Send notifications to students/parents
- Export reports for analysis

## 🔒 Security Features

### Authentication
- Password hashing with PHP's `password_hash()`
- Session management
- Role-based access control

### Data Protection
- Input sanitization and validation
- SQL injection prevention with prepared statements
- CORS headers for API security
- Error handling without sensitive data exposure

## 📱 Mobile Features

### Offline Support
- Local data caching with SharedPreferences
- Offline attendance marking (sync when online)
- Offline report viewing

### Performance
- Optimized database queries
- Image caching
- Lazy loading for large lists
- Efficient state management

## 🧪 Testing

### Manual Testing Checklist
- [ ] User registration and login
- [ ] Role-based dashboard access
- [ ] Attendance code generation
- [ ] Attendance marking and validation
- [ ] Report generation
- [ ] User management operations
- [ ] API endpoint functionality

### Test Data
```sql
-- Insert test users
INSERT INTO users (name, email, password, role, department) VALUES
('John Student', 'student@test.com', '$2y$10$...', 'student', 'Computer Science'),
('Jane Teacher', 'teacher@test.com', '$2y$10$...', 'teacher', 'Mathematics'),
('Mike Counselor', 'counselor@test.com', '$2y$10$...', 'counselor', 'Psychology');
```

## 🚀 Deployment

### Production Setup
1. **Server Requirements**
   - PHP 8.0+
   - MySQL 8.0+
   - Apache/Nginx
   - SSL Certificate

2. **Database Migration**
   ```bash
   # Export production database
   mysqldump -u username -p attendance_system > production_backup.sql
   ```

3. **API Configuration**
   ```php
   // Update base URL for production
   static const String baseUrl = 'https://yourdomain.com/api';
   ```

4. **Flutter Build**
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS (requires macOS)
   flutter build ios --release
   ```

## 📈 Future Enhancements

### Planned Features
- **QR Code Integration** for easier attendance marking
- **Push Notifications** for attendance reminders
- **Biometric Authentication** for enhanced security
- **Advanced Analytics** with machine learning
- **Mobile App** for parents to track student attendance
- **Integration** with existing school management systems

### Technical Improvements
- **Real-time Updates** using WebSockets
- **Advanced Caching** with Redis
- **Microservices Architecture** for scalability
- **Docker Containerization** for easy deployment
- **Automated Testing** with unit and integration tests

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- **Email**: support@sams.com
- **Documentation**: [Project Wiki]
- **Issues**: [GitHub Issues]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- PHP community for backend tools
- Open source contributors

---

**Smart Attendance Management System (SAMS)** - Making attendance tracking simple, efficient, and beautiful! 🎓✨
