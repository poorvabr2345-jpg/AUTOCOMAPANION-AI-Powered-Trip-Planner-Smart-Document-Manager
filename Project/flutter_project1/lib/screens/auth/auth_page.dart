import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/home/home_page.dart';
import '../../utils/responsive_helper.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  bool loadingEmail = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  late AnimationController _backgroundController;
  late Animation<Offset> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Create slow moving background animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _backgroundAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.1, -0.05),
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    // Loop the animation back and forth
    _backgroundController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  // ==========================================================
  //                    EMAIL LOGIN
  // ==========================================================
  Future<void> _loginEmail() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      _error("Please enter email and password");
      return;
    }

    setState(() => loadingEmail = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      _goHome();
    } on FirebaseAuthException catch (e) {
      _error(e.message ?? "Login failed");
    }

    setState(() => loadingEmail = false);
  }

  Future<void> _registerEmail() async {
    setState(() => loadingEmail = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      _error("Account created. Please login.");
    } on FirebaseAuthException catch (e) {
      _error(e.message ?? "Registration failed");
    }
    setState(() => loadingEmail = false);
  }

  // ==========================================================
  //                    HELPERS
  // ==========================================================
  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF87CEEB),
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  // ==========================================================
  //                     UI - CAR BACKGROUND DESIGN
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _backgroundAnimation.value.dx * size.width,
                  _backgroundAnimation.value.dy * size.height,
                ),
                child: Transform.scale(
                  scale: 1.2, // Scale up to allow movement without showing edges
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=1200',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF87CEEB).withOpacity(0.80),
                  Colors.white.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          ResponsiveHelper.responsive(
            context: context,
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side - Login Form
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: _buildLoginForm(),
            ),
          ),
        ),
        
        // Right Side - AutoCompanion Branding
        Expanded(
          flex: 5,
          child: _buildBrandingSection(),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo Text
        const Text(
          "AutoCompanion",
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        const Text(
          "Sign in to continue your journey",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 40),
                        
        // Email Field
        const Text(
          "Email",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: emailCtrl,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(passFocus),
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: "Enter your email",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF87CEEB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF87CEEB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 20),
        
        // Password Field
        const Text(
          "Password",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passCtrl,
          focusNode: passFocus,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loginEmail(),
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: "Enter your password",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF87CEEB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF87CEEB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 30),
        
        // Login Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: loadingEmail ? null : _loginEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF87CEEB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: loadingEmail
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "or",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 20),
        
        // Social Login Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata, "Google"),
            const SizedBox(width: 16),
            _buildSocialButton(Icons.facebook, "Facebook"),
            const SizedBox(width: 16),
            _buildSocialButton(Icons.apple, "Apple"),
          ],
        ),
        const SizedBox(height: 30),
        
        // Create Account Link
        Center(
          child: TextButton(
            onPressed: loadingEmail ? null : _registerEmail,
            child: RichText(
              text: const TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(color: Colors.black54, fontSize: 14),
                children: [
                  TextSpan(
                    text: "Sign Up",
                    style: TextStyle(
                      color: Color(0xFF87CEEB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo/Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.two_wheeler,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          
          // AutoCompanion Text
          const Text(
            "AutoCompanion",
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -1,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Subtitle
          Text(
            "Your intelligent travel companion",
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 20,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: () {},
        tooltip: label,
      ),
    );
  }
}
