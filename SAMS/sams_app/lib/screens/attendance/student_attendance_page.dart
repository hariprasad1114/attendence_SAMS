import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/animated_header.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _markAttendance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final studentId = authService.currentUser!.id;

      // First validate the code
      final isValid = await ApiService.validateAttendanceCode(_codeController.text.trim());
      
      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid attendance code. Please check and try again.';
          _isLoading = false;
        });
        return;
      }

      // Mark attendance
      final success = await ApiService.markAttendance(studentId, _codeController.text.trim());
      
      if (success) {
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
        
        // Show success animation and navigate back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to mark attendance. Please try again.';
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
              AppColors.studentColor,
              Color(0xFF1D4ED8),
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
                  title: 'Mark Attendance',
                  subtitle: 'Enter the attendance code provided by your teacher',
                  icon: Icons.qr_code_scanner,
                  color: Colors.white,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                
                const SizedBox(height: 60),
                
                // Attendance Form Card
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
                        // Code Input Field
                        InputField(
                          controller: _codeController,
                          label: 'Attendance Code',
                          hint: 'Enter the 6-digit code',
                          prefixIcon: Icons.vpn_key,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the attendance code';
                            }
                            if (value.length < 4) {
                              return 'Code must be at least 4 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
                        
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
                        
                        // Submit Button
                        CustomButton(
                          text: 'Mark Attendance',
                          onPressed: _isLoading ? null : _markAttendance,
                          isLoading: _isLoading,
                          icon: Icons.check_circle,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Instructions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.info.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Instructions',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Enter the attendance code provided by your teacher\n'
                                '• Make sure you are in the correct class\n'
                                '• Attendance can only be marked once per session',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
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
                ).animate().fadeIn(delay: 800.ms),
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
                    'Attendance Marked Successfully!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Your attendance has been recorded for this session.',
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
