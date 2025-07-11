import 'package:flutter/material.dart';
import 'package:v_store/services/auth_service_new.dart';
import 'package:v_store/services/user_service.dart';
import 'package:v_store/models/user.dart';

class UserProfileEditScreen extends StatefulWidget {
  final UserProfile userProfile;

  const UserProfileEditScreen({super.key, required this.userProfile});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genders = ['male', 'female', 'other'];
  final Map<String, String> _genderLabels = {
    'male': 'Nam',
    'female': 'Nữ',
    'other': 'Khác',
  };

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.userProfile.displayName,
    );
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(
      text: widget.userProfile.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.userProfile.address ?? '',
    );
    _cityController = TextEditingController(
      text: widget.userProfile.city ?? '',
    );
    _countryController = TextEditingController(
      text: widget.userProfile.country ?? 'Việt Nam',
    );
    _selectedDate = widget.userProfile.dateOfBirth;
    _selectedGender = widget.userProfile.gender;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfilePictureSection(),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Thông tin cơ bản'),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên hiển thị',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên hiển thị';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: widget.userProfile.isEmailVerified
                            ? const Icon(Icons.verified, color: Colors.green)
                            : const Icon(Icons.warning, color: Colors.orange),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!Validators.isValidEmail(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        suffixIcon: widget.userProfile.isPhoneVerified
                            ? const Icon(Icons.verified, color: Colors.green)
                            : null,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!Validators.isValidPhone(value)) {
                            return 'Số điện thoại không hợp lệ';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Chọn ngày sinh',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Giới tính',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(_genderLabels[gender]!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Thông tin địa chỉ'),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Thành phố',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Quốc gia',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Thông tin tài khoản'),
                    const SizedBox(height: 16),

                    Card(
                      child: ListTile(
                        leading: _getProviderIcon(
                          widget.userProfile.loginProvider,
                        ),
                        title: Text(
                          'Đăng nhập bằng ${_getProviderName(widget.userProfile.loginProvider)}',
                        ),
                        subtitle: Text(
                          'Tài khoản được tạo: ${_formatDate(widget.userProfile.createdAt)}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (widget.userProfile.loginProvider != 'google')
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _switchToGoogleLogin,
                          icon: const Icon(Icons.login),
                          label: const Text('Chuyển sang đăng nhập Google'),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: widget.userProfile.photoURL != null
                ? NetworkImage(widget.userProfile.photoURL!)
                : null,
            child: widget.userProfile.photoURL == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _changeProfilePicture,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Thay đổi ảnh'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng thay đổi ảnh sẽ được phát triển sau'),
      ),
    );
  }

  void _switchToGoogleLogin() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userProfile = await AuthService.signInWithGoogle();

      if (userProfile != null) {
        await UserService.switchLoginProvider(userProfile.userId, 'google');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã chuyển sang đăng nhập Google thành công'),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chuyển đổi tài khoản: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final updatedProfile =
          await UserService.updateUserProfile(widget.userProfile.userId, {
            'displayName': _displayNameController.text.trim(),
            'email': _emailController.text.trim(),
            'phoneNumber': _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            'dateOfBirth': _selectedDate,
            'gender': _selectedGender,
            'address': _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            'city': _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            'country': _countryController.text.trim().isEmpty
                ? null
                : _countryController.text.trim(),
          });

      if (_emailController.text.trim() != widget.userProfile.email) {
        await AuthService.updateEmail(_emailController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công')),
        );
        Navigator.of(context).pop(updatedProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật thông tin: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Icon _getProviderIcon(String provider) {
    switch (provider) {
      case 'google':
        return const Icon(Icons.account_circle, color: Colors.red);
      case 'facebook':
        return const Icon(Icons.people, color: Colors.blue);
      case 'email':
      default:
        return const Icon(Icons.email, color: Colors.grey);
    }
  }

  String _getProviderName(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'facebook':
        return 'Facebook';
      case 'email':
      default:
        return 'Email';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone) && phone.length >= 10;
  }
}
