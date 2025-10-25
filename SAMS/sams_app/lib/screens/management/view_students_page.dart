import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class ViewStudentsPage extends StatefulWidget {
  const ViewStudentsPage({super.key});

  @override
  State<ViewStudentsPage> createState() => _ViewStudentsPageState();
}

class _ViewStudentsPageState extends State<ViewStudentsPage> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    // Simulate loading students from API
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _students = [
          {
            'id': 'ST001',
            'name': 'John Doe',
            'email': 'john@example.com',
            'department': 'Computer Science',
            'phone': '+1234567890',
            'attendance': 85.5,
            'status': 'Active',
          },
          {
            'id': 'ST002',
            'name': 'Jane Smith',
            'email': 'jane@example.com',
            'department': 'Mathematics',
            'phone': '+1234567891',
            'attendance': 78.2,
            'status': 'Active',
          },
          {
            'id': 'ST003',
            'name': 'Mike Johnson',
            'email': 'mike@example.com',
            'department': 'Physics',
            'phone': '+1234567892',
            'attendance': 92.1,
            'status': 'Active',
          },
          {
            'id': 'ST004',
            'name': 'Sarah Wilson',
            'email': 'sarah@example.com',
            'department': 'Chemistry',
            'phone': '+1234567893',
            'attendance': 65.8,
            'status': 'Active',
          },
          {
            'id': 'ST005',
            'name': 'David Brown',
            'email': 'david@example.com',
            'department': 'English',
            'phone': '+1234567894',
            'attendance': 88.3,
            'status': 'Active',
          },
        ];
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> get _filteredStudents {
    var filtered = _students;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((student) =>
          student['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student['id'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_selectedFilter != 'All') {
      filtered = filtered.where((student) => student['department'] == _selectedFilter).toList();
    }
    
    return filtered;
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
              AppColors.adminColor,
              Color(0xFFDC2626),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Student Management',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        // Navigate to add student page
                      },
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Search Field
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Computer Science'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Mathematics'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Physics'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Chemistry'),
                    const SizedBox(width: 8),
                    _buildFilterChip('English'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Students List
        Expanded(
          child: _filteredStudents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    return _buildStudentCard(_filteredStudents[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: AppColors.adminColor.withOpacity(0.2),
      checkmarkColor: AppColors.adminColor,
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final attendance = student['attendance'] as double;
    final attendanceColor = attendance >= 85 ? AppColors.success :
                           attendance >= 75 ? AppColors.info :
                           attendance >= 70 ? AppColors.warning : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: AppColors.adminColor.withOpacity(0.1),
            child: Text(
              student['name'][0],
              style: TextStyle(
                color: AppColors.adminColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'ID: ${student['id']} • ${student['department']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  student['email'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          // Attendance and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: attendanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${attendance.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: attendanceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () => _editStudent(student),
                    color: AppColors.info,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 16),
                    onPressed: () => _deleteStudent(student),
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _editStudent(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${student['name']}'),
        content: const Text('Student editing form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete functionality
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
