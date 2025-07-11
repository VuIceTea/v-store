import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v_store/services/registration_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({super.key, required this.email});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get _isOTPComplete {
    return _otpCode.length == 6;
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});

    if (_isOTPComplete) {
      _verifyOTP();
    }
  }

  Future<void> _verifyOTP() async {
    if (!_isOTPComplete) {
      _showErrorDialog('Vui lòng nhập đầy đủ mã OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Starting OTP verification from UI...');
      print('📧 Email: ${widget.email}');
      print('🔢 OTP Code: $_otpCode');

      final isValid =
          await RegistrationService.verifyOTPAndCompleteRegistration(
            email: widget.email,
            otp: _otpCode,
          );

      print('📊 Registration result: $isValid');

      if (isValid) {
        print('✅ Registration successful, showing success dialog');
        _showSuccessDialog();
      } else {
        print('❌ OTP verification failed');
        _showErrorDialog('Mã OTP không chính xác. Vui lòng thử lại.');
        _clearOTP();
      }
    } catch (e) {
      print('💥 Exception in _verifyOTP: $e');
      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      _clearOTP();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearOTP() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOTP() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isResending = true;
      _resendCooldown = 60;
    });

    try {
      await RegistrationService.resendOTP(widget.email);

      _showSuccessSnackBar('Mã OTP mới đã được gửi đến email của bạn');

      _startCooldownTimer();
    } catch (e) {
      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _startCooldownTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
        _startCooldownTimer();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Thành công!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: Text(
            'Tài khoản của bạn đã được tạo thành công!\nBạn có thể đăng nhập ngay bây giờ.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Colors.green,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/sign-in');
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 24),
              SizedBox(width: 8),
              Text(
                'Lỗi',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _fadeAnimation != null && _slideAnimation != null
                      ? FadeTransition(
                          opacity: _fadeAnimation!,
                          child: SlideTransition(
                            position: _slideAnimation!,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 40),

                                  // Icon and title
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),

                                  SizedBox(height: 32),

                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Xác thực\nTài khoản',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 24),

                                  Text(
                                    'Chúng tôi đã gửi mã xác thực 6 chữ số đến',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    widget.email,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF667eea),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  SizedBox(height: 40),

                                  // OTP Input Fields
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(6, (index) {
                                      return Container(
                                        width: 50,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          controller: _controllers[index],
                                          focusNode: _focusNodes[index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Montserrat',
                                            color: Color(0xFF667eea),
                                          ),
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            counterText: '',
                                            filled: true,
                                            fillColor: Colors.grey.shade300,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Color(0xFF667eea),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) =>
                                              _onOTPChanged(value, index),
                                        ),
                                      );
                                    }),
                                  ),

                                  SizedBox(height: 40),

                                  // Verify button
                                  Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: _isOTPComplete
                                          ? LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                Colors.grey.shade300,
                                                Colors.grey.shade400,
                                              ],
                                            ),
                                      boxShadow: _isOTPComplete
                                          ? [
                                              BoxShadow(
                                                color: Color(
                                                  0xFF667eea,
                                                ).withOpacity(0.4),
                                                blurRadius: 15,
                                                offset: Offset(0, 8),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading || !_isOTPComplete
                                          ? null
                                          : _verifyOTP,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Xác thực',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),

                                  SizedBox(height: 32),

                                  // Resend OTP
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Không nhận được mã? ',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:
                                            _resendCooldown > 0 || _isResending
                                            ? null
                                            : _resendOTP,
                                        child: Text(
                                          _resendCooldown > 0
                                              ? 'Gửi lại (${_resendCooldown}s)'
                                              : _isResending
                                              ? 'Đang gửi...'
                                              : 'Gửi lại',
                                          style: TextStyle(
                                            color:
                                                _resendCooldown > 0 ||
                                                    _isResending
                                                ? Colors.grey.shade400
                                                : Color(0xFF667eea),
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
