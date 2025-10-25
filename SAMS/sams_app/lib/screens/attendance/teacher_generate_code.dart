import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/animated_header.dart';
import '../../models/attendance.dart';

class TeacherGenerateCode extends StatefulWidget {
  const TeacherGenerateCode({super.key});

  @override
  State<TeacherGenerateCode> createState() => _TeacherGenerateCodeState();
}

class _TeacherGenerateCodeState extends State<TeacherGenerateCode> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _classNameController = TextEditingController();
  final _maxUsesController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCodeGenerated = false;
  AttendanceCode? _generatedCode;
  String? _errorMessage;
  
  int _selectedValidityHours = 1;
  final List<int> _validityOptions = [1, 2, 3, 4, 6, 8];

  @override
  void dispose() {
    _subjectController.dispose();
    _classNameController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final teacherId = authService.currentUser!.id;
      final teacherName = authService.currentUser!.name;

      final maxUses = _maxUsesController.text.isNotEmpty 
          ? int.tryParse(_maxUsesController.text) 
          : null;

      final code = await ApiService.generateAttendanceCode(
        teacherId,
        _subjectController.text.trim(),
        className: _classNameController.text.trim().isEmpty 
            ? null 
            : _classNameController.text.trim(),
        maxUses: maxUses,
        validity: Duration(hours: _selectedValidityHours),
      );

      setState(() {
        _generatedCode = code;
        _isCodeGenerated = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate code: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCodeGenerated && _generatedCode != null) {
      return _buildCodeGeneratedScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.teacherColor,
              Color(0xFF047857),
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
                  title: 'Generate Code',
                  subtitle: 'Create a new attendance code for your class',
                  icon: Icons.qr_code,
                  color: Colors.white,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                
                const SizedBox(height: 60),
                
                // Code Generation Form Card
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
                        // Subject Field
                        InputField(
                          controller: _subjectController,
                          label: 'Subject',
                          hint: 'Enter subject name',
                          prefixIcon: Icons.book,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the subject name';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Class Name Field
                        InputField(
                          controller: _classNameController,
                          label: 'Class Name (Optional)',
                          hint: 'e.g., Class 10A, Section B',
                          prefixIcon: Icons.class_,
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Validity Duration
                        Text(
                          'Code Validity',
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
                            child: DropdownButton<int>(
                              value: _selectedValidityHours,
                              isExpanded: true,
                              items: _validityOptions.map((hours) {
                                return DropdownMenuItem<int>(
                                  value: hours,
                                  child: Text('$hours ${hours == 1 ? 'hour' : 'hours'}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedValidityHours = value!;
                                });
                              },
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3),
                        
                        const SizedBox(height: 16),
                        
                        // Max Uses Field
                        InputField(
                          controller: _maxUsesController,
                          label: 'Maximum Uses (Optional)',
                          hint: 'Leave empty for unlimited',
                          prefixIcon: Icons.people,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final maxUses = int.tryParse(value);
                              if (maxUses == null || maxUses <= 0) {
                                return 'Please enter a valid number';
                              }
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3),
                        
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
                        
                        // Generate Button
                        CustomButton(
                          text: 'Generate Code',
                          onPressed: _isLoading ? null : _generateCode,
                          isLoading: _isLoading,
                          icon: Icons.add_circle,
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                        
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
                                '• Share the generated code with your students\n'
                                '• Students can use this code to mark attendance\n'
                                '• Code will expire after the selected duration\n'
                                '• You can set a maximum number of uses',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
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

  Widget _buildCodeGeneratedScreen() {
    final code = _generatedCode!;
    
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Success Header
                const AnimatedHeader(
                  title: 'Code Generated!',
                  subtitle: 'Share this code with your students',
                  icon: Icons.check_circle,
                  color: Colors.white,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                
                const SizedBox(height: 40),
                
                // Code Display Card
                Container(
                  padding: const EdgeInsets.all(32),
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
                  child: Column(
                    children: [
                      // Code Display
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Attendance Code',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              code.code,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Code Details
                      _buildCodeDetail('Subject', code.subject),
                      _buildCodeDetail('Class', code.className ?? 'Not specified'),
                      _buildCodeDetail('Expires', _formatDateTime(code.expiresAt)),
                      _buildCodeDetail('Max Uses', code.maxUses?.toString() ?? 'Unlimited'),
                      _buildCodeDetail('Current Uses', code.currentUses.toString()),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Copy Code',
                              onPressed: () => _copyCode(code.code),
                              backgroundColor: AppColors.info,
                              icon: Icons.copy,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'Share',
                              onPressed: () => _shareCode(code),
                              backgroundColor: AppColors.secondary,
                              icon: Icons.share,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                
                const SizedBox(height: 40),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Generate Another',
                        onPressed: () {
                          setState(() {
                            _isCodeGenerated = false;
                            _generatedCode = null;
                            _subjectController.clear();
                            _classNameController.clear();
                            _maxUsesController.clear();
                          });
                        },
                        isOutlined: true,
                        backgroundColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Back to Dashboard',
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _copyCode(String code) {
    // In a real app, you would use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copied: $code'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareCode(AttendanceCode code) {
    // In a real app, you would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing code: ${code.code}'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
