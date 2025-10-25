-- Smart Attendance Management System (SAMS) Database Schema
-- Created for XAMPP MySQL

-- Create database
CREATE DATABASE IF NOT EXISTS attendance_system;
USE attendance_system;

-- Users table - stores all user information (students, teachers, admins, counselors)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('student', 'teacher', 'admin', 'counselor') NOT NULL,
    student_id VARCHAR(20) UNIQUE NULL,
    department VARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_student_id (student_id),
    INDEX idx_department (department)
);

-- Attendance codes table - stores teacher-generated attendance codes
CREATE TABLE IF NOT EXISTS attendance_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    teacher_id INT NOT NULL,
    teacher_name VARCHAR(100) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    class_name VARCHAR(100) NULL,
    max_uses INT NULL,
    current_uses INT DEFAULT 0,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_code (code),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_subject (subject),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_active (is_active)
);

-- Attendance table - stores attendance records
CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    teacher_id INT NOT NULL,
    teacher_name VARCHAR(100) NOT NULL,
    attendance_code VARCHAR(10) NULL,
    status ENUM('present', 'absent', 'late') DEFAULT 'present',
    notes TEXT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (attendance_code) REFERENCES attendance_codes(code) ON DELETE SET NULL,
    INDEX idx_student_id (student_id),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_subject (subject),
    INDEX idx_date (date),
    INDEX idx_status (status),
    INDEX idx_attendance_code (attendance_code)
);

-- Subjects table - stores available subjects
CREATE TABLE IF NOT EXISTS subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(100) NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_department (department)
);

-- Departments table - stores available departments
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
);

-- Notifications table - stores system notifications
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'warning', 'error', 'success') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
);

-- System settings table - stores system configuration
CREATE TABLE IF NOT EXISTS system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NULL,
    description TEXT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_setting_key (setting_key)
);

-- Insert default admin user
INSERT INTO users (name, email, password, role, department) VALUES 
('System Admin', 'admin@sams.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'Administration');

-- Insert default departments
INSERT INTO departments (name, description) VALUES 
('Computer Science', 'Computer Science and Engineering'),
('Mathematics', 'Mathematics and Statistics'),
('Physics', 'Physics and Applied Sciences'),
('Chemistry', 'Chemistry and Chemical Engineering'),
('English', 'English Language and Literature'),
('Biology', 'Biological Sciences'),
('Economics', 'Economics and Business'),
('Business Administration', 'Business and Management Studies');

-- Insert default subjects
INSERT INTO subjects (name, department, description) VALUES 
('Data Structures', 'Computer Science', 'Fundamental data structures and algorithms'),
('Calculus', 'Mathematics', 'Differential and integral calculus'),
('Mechanics', 'Physics', 'Classical mechanics and dynamics'),
('Organic Chemistry', 'Chemistry', 'Structure and reactions of organic compounds'),
('Literature', 'English', 'Study of literary works and analysis'),
('Cell Biology', 'Biology', 'Structure and function of cells'),
('Microeconomics', 'Economics', 'Individual economic behavior and markets'),
('Management Principles', 'Business Administration', 'Fundamental principles of management');

-- Insert default system settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES 
('attendance_threshold', '75', 'Minimum attendance percentage threshold'),
('code_validity_hours', '1', 'Default validity period for attendance codes in hours'),
('max_code_uses', '50', 'Default maximum uses for attendance codes'),
('system_name', 'SAMS', 'System name'),
('institution_name', 'Smart University', 'Institution name');

-- Create views for easier querying

-- View for student attendance summary
CREATE VIEW student_attendance_summary AS
SELECT 
    u.id as student_id,
    u.name as student_name,
    u.student_id as student_number,
    u.department,
    COUNT(a.id) as total_classes,
    SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_classes,
    SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_classes,
    SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END) as late_classes,
    ROUND(
        (SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.id)), 2
    ) as attendance_percentage
FROM users u
LEFT JOIN attendance a ON u.id = a.student_id
WHERE u.role = 'student'
GROUP BY u.id, u.name, u.student_id, u.department;

-- View for teacher activity summary
CREATE VIEW teacher_activity_summary AS
SELECT 
    u.id as teacher_id,
    u.name as teacher_name,
    u.department,
    COUNT(DISTINCT ac.id) as codes_generated,
    COUNT(DISTINCT a.id) as attendance_marked,
    COUNT(DISTINCT a.student_id) as unique_students,
    MAX(ac.created_at) as last_code_generated
FROM users u
LEFT JOIN attendance_codes ac ON u.id = ac.teacher_id
LEFT JOIN attendance a ON u.id = a.teacher_id
WHERE u.role = 'teacher'
GROUP BY u.id, u.name, u.department;

-- Create stored procedures

-- Procedure to clean up expired attendance codes
DELIMITER //
CREATE PROCEDURE CleanupExpiredCodes()
BEGIN
    UPDATE attendance_codes 
    SET is_active = FALSE 
    WHERE expires_at < NOW() AND is_active = TRUE;
    
    SELECT ROW_COUNT() as expired_codes_deactivated;
END //
DELIMITER ;

-- Procedure to generate attendance report for a student
DELIMITER //
CREATE PROCEDURE GetStudentAttendanceReport(
    IN p_student_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        a.subject,
        COUNT(*) as total_classes,
        SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_classes,
        SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_classes,
        SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END) as late_classes,
        ROUND(
            (SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
        ) as attendance_percentage
    FROM attendance a
    WHERE a.student_id = p_student_id
    AND DATE(a.date) BETWEEN p_start_date AND p_end_date
    GROUP BY a.subject
    ORDER BY a.subject;
END //
DELIMITER ;

-- Create triggers

-- Trigger to update attendance code usage count
DELIMITER //
CREATE TRIGGER update_code_usage 
AFTER INSERT ON attendance
FOR EACH ROW
BEGIN
    IF NEW.attendance_code IS NOT NULL THEN
        UPDATE attendance_codes 
        SET current_uses = current_uses + 1 
        WHERE code = NEW.attendance_code;
    END IF;
END //
DELIMITER ;

-- Trigger to deactivate attendance code when max uses reached
DELIMITER //
CREATE TRIGGER check_max_uses 
AFTER UPDATE ON attendance_codes
FOR EACH ROW
BEGIN
    IF NEW.max_uses IS NOT NULL AND NEW.current_uses >= NEW.max_uses THEN
        UPDATE attendance_codes 
        SET is_active = FALSE 
        WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;

-- Grant permissions (adjust as needed for your setup)
-- GRANT ALL PRIVILEGES ON attendance_system.* TO 'sams_user'@'localhost' IDENTIFIED BY 'sams_password';
-- FLUSH PRIVILEGES;

-- Display completion message
SELECT 'SAMS Database Schema Created Successfully!' as Status;
