import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/animated_header.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String _selectedDepartment = 'Computer Science';

  final List<String> _departments = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'English',
    'Biology',
    'Economics',
    'Business Administration',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'student_id': _studentIdController.text.trim(),
        'phone': _phoneController.text.trim(),
        'department': _selectedDepartment,
        'role': 'student',
        'password': _passwordController.text,
      };

      final success = await ApiService.addUser(
        User.fromJson(student),
        _passwordController.text,
      );

      if (success) {
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
        
        // Navigate back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to add student. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.adminColor,
              Color(0xFFDC2626),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Header
                const AnimatedHeader(
                  title: 'Add Student',
                  subtitle: 'Register a new student in the system',
                  icon: Icons.person_add,
                  color: Colors.white,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                
                const SizedBox(height: 60),
                
                // Student Registration Form Card
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field
                        InputField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter student full name',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the student name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Email Field
                        InputField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter student email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Student ID Field
                        InputField(
                          controller: _studentIdController,
                          label: 'Student ID',
                          hint: 'Enter unique student ID',
                          prefixIcon: Icons.badge,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the student ID';
                            }
                            if (value.length < 3) {
                              return 'Student ID must be at least 3 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Department Field
                        Text(
                          'Department',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDepartment,
                              isExpanded: true,
                              items: _departments.map((department) {
                                return DropdownMenuItem<String>(
                                  value: department,
                                  child: Text(department),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartment = value!;
                                });
                              },
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Phone Field
                        InputField(
                          controller: _phoneController,
                          label: 'Phone Number (Optional)',
                          hint: 'Enter phone number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        InputField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter temporary password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 24),
                        
                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideX(begin: -0.3),
                        
                        // Add Button
                        CustomButton(
                          text: 'Add Student',
                          onPressed: _isLoading ? null : _addStudent,
                          isLoading: _isLoading,
                          icon: Icons.person_add,
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
                
                const SizedBox(height: 40),
                
                // Back Button
                CustomButton(
                  text: 'Back to Dashboard',
                  onPressed: () => Navigator.pop(context),
                  isOutlined: true,
                  backgroundColor: Colors.white,
                  textColor: Colors.white,
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.success,
              Color(0xFF047857),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Animation
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.white,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Success Message
                  Text(
                    'Student Added Successfully!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'The student has been registered in the system and can now login.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 48),
                  
                  // Auto-redirect message
                  Text(
                    'Redirecting to dashboard...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
