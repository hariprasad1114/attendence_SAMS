import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/animated_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isPasswordVisible = false;

  final List<Map<String, dynamic>> _roles = [
    {'value': 'student', 'label': 'Student', 'color': AppColors.studentColor, 'icon': Icons.school},
    {'value': 'teacher', 'label': 'Teacher', 'color': AppColors.teacherColor, 'icon': Icons.person},
    {'value': 'admin', 'label': 'Admin', 'color': AppColors.adminColor, 'icon': Icons.admin_panel_settings},
    {'value': 'counselor', 'label': 'Counselor', 'color': AppColors.counselorColor, 'icon': Icons.psychology},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );

    if (success && mounted) {
      // Navigate to appropriate dashboard based on role
      switch (_selectedRole) {
        case 'student':
          context.go('/student-dashboard');
          break;
        case 'teacher':
          context.go('/teacher-dashboard');
          break;
        case 'admin':
          context.go('/admin-dashboard');
          break;
        case 'counselor':
          context.go('/counselor-dashboard');
          break;
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Animated Header
                const AnimatedHeader(
                  title: 'SAMS',
                  subtitle: 'Smart Attendance Management System',
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                
                const SizedBox(height: 60),
                
                // Login Form Card
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
                        // Role Selection
                        Text(
                          'Select Your Role',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Role Cards
                        ..._roles.map((role) => _buildRoleCard(role)).toList(),
                        
                        const SizedBox(height: 32),
                        
                        // Email Field
                        InputField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        InputField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 32),
                        
                        // Login Button
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return CustomButton(
                              text: 'Login',
                              onPressed: authService.isLoading ? null : _handleLogin,
                              isLoading: authService.isLoading,
                            );
                          },
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
                
                const SizedBox(height: 40),
                
                // Footer
                Text(
                  '© 2024 SAMS - Smart Attendance Management System',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role) {
    final isSelected = _selectedRole == role['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role['value'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? role['color'].withOpacity(0.1) : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? role['color'] : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? role['color'] : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  role['icon'],
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                role['label'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? role['color'] : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: role['color'],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
