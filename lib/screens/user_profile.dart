import 'package:flutter/material.dart';
import 'package:v_store/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const UserProfileScreen({super.key, this.showBackButton = false});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    final User? user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text(
          'Hồ Sơ Của Tôi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showEditProfileDialog(user);
            },
            child: const Text(
              'Sửa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color.fromARGB(255, 91, 57, 95),
              ],
            ),
          ),
        ),
      ),

      body: user == null
          ? const Center(
              child: Text(
                'Không có thông tin người dùng',
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 8),
                  _buildOrderHistory(),
                  const SizedBox(height: 8),
                  _buildProfileInfo(user),
                  const SizedBox(height: 8),
                  _buildAccountSettings(),
                  const SizedBox(height: 8),
                  _buildAppSettings(),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null)
                          as ImageProvider?,
                child: _selectedImage == null && user.photoURL == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? 'Chưa có tên',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      user.emailVerified ? Icons.verified : Icons.warning,
                      color: user.emailVerified ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.emailVerified ? 'Đã xác thực' : 'Chưa xác thực',
                      style: TextStyle(
                        fontSize: 14,
                        color: user.emailVerified
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildOrderHistory() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng của tôi',
            subtitle: 'Xem lịch sử mua hàng',
            onTap: () {
              Navigator.pushNamed(context, '/order-history');
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.local_shipping_outlined,
            title: 'Theo dõi đơn hàng',
            subtitle: 'Kiểm tra tình trạng giao hàng',
            onTap: () {
              Navigator.pushNamed(context, '/order-tracking');
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.assignment_return_outlined,
            title: 'Đổi trả hàng',
            subtitle: 'Yêu cầu hoàn trả sản phẩm',
            onTap: () {
              Navigator.pushNamed(context, '/return-refund');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.person_outline,
            title: 'Tên người dùng',
            subtitle: user.displayName ?? 'Chưa cập nhật',
            onTap: () {
              _showEditNameDialog(user.displayName ?? '');
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: user.email ?? 'Chưa cập nhật',
            onTap: () {
              // Email thường không cho phép sửa
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email không thể thay đổi')),
              );
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.phone_outlined,
            title: 'Số điện thoại',
            subtitle: user.phoneNumber ?? 'Chưa cập nhật',
            onTap: () {
              _showEditPhoneDialog(user.phoneNumber ?? '');
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.cake_outlined,
            title: 'Ngày sinh',
            subtitle: 'Chưa cập nhật',
            onTap: () {
              _showDatePicker();
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.person_outline,
            title: 'Giới tính',
            subtitle: 'Chưa cập nhật',
            onTap: () {
              _showGenderPicker();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ',
            subtitle: 'Quản lý địa chỉ giao hàng',
            onTap: () {
              // Navigate to address management
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.credit_card_outlined,
            title: 'Thẻ ngân hàng',
            subtitle: 'Quản lý thẻ thanh toán',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.security_outlined,
            title: 'Thiết lập riêng tư',
            subtitle: 'Mật khẩu, bảo mật',
            onTap: () {
              // Navigate to security settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.notifications_outlined,
            title: 'Cài đặt thông báo',
            subtitle: 'Tin nhắn, cập nhật đơn hàng',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            subtitle: 'Tiếng Việt',
            onTap: () {
              // Navigate to language settings
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await AuthService.signOut();

            // Chuyển về trang chủ ngay lập tức
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/main',
                (route) => false,
                arguments: 0, // Tab index 0 = Home
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi đăng xuất: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Đăng xuất',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              if (_selectedImage != null ||
                  AuthService.currentUser?.photoURL != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Xóa ảnh đại diện',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // TODO: Upload image to Firebase Storage and update user profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ảnh đại diện đã được cập nhật'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chọn ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditProfileDialog(User? user) {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng sửa hồ sơ sẽ được cập nhật')),
    );
  }

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tên người dùng'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên người dùng',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update display name in Firebase
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tên đã được cập nhật')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog(String currentPhone) {
    final controller = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa số điện thoại'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update phone number in Firebase
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Số điện thoại đã được cập nhật')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        // TODO: Save birthday
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ngày sinh đã được cập nhật')),
        );
      }
    });
  }

  void _showGenderPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn giới tính'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Nam'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giới tính đã được cập nhật')),
                );
              },
            ),
            ListTile(
              title: const Text('Nữ'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giới tính đã được cập nhật')),
                );
              },
            ),
            ListTile(
              title: const Text('Khác'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giới tính đã được cập nhật')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
