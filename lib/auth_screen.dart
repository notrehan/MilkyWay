import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _bg = Color(0xFFFAFAF8);
const _ink = Color(0xFF252622);
const _muted = Color(0xFF777873);
const _accent = Color(0xFF8B80B5);
const _border = Color(0xFFE8E8E3);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      if (_isLogin) {
        await client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final response = await client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'display_name': _nameController.text.trim()},
        );
        if (response.session == null && mounted) {
          _message('Account created. Check your email to confirm your account.');
        }
      }
    } on AuthException catch (e) {
      if (mounted) _message(e.message);
    } catch (e) {
      if (mounted) _message('Something went wrong. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) => InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: _muted),
    hintStyle: const TextStyle(color: Color(0xFF999A94)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _accent, width: 1.5)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: _accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(21)),
                        child: const Icon(Icons.rocket_launch_rounded, color: _accent, size: 32),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('MILKYWAY', textAlign: TextAlign.center, style: TextStyle(color: _ink, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: 3)),
                    const SizedBox(height: 8),
                    Text(_isLogin ? 'Welcome back, space traveller.' : 'Your next adventure starts here.', textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 14)),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: const Color(0xFFF0F0ED), borderRadius: BorderRadius.circular(13)),
                      child: Row(children: [
                        _tab('Log in', _isLogin, () => setState(() => _isLogin = true)),
                        _tab('Sign up', !_isLogin, () => setState(() => _isLogin = false)),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _decoration('Display name', hint: 'What should we call you?'),
                        validator: (v) => !_isLogin && (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: _decoration('Email address', hint: 'you@example.com'),
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        if (email.isEmpty || !email.contains('@') || !email.contains('.')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      autofillHints: _isLogin ? const [AutofillHints.password] : const [AutofillHints.newPassword],
                      decoration: _decoration('Password', hint: _isLogin ? 'Your password' : 'At least 6 characters', suffix: IconButton(icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _muted), onPressed: () => setState(() => _hidePassword = !_hidePassword))),
                      validator: (v) {
                        if ((v ?? '').length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(backgroundColor: _ink, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_isLogin ? 'Log in' : 'Create account', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(_isLogin ? 'New to the galaxy? Create an account.' : 'By joining, you agree to explore responsibly.', textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12, height: 1.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(color: selected ? _ink : _muted, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    ),
  );
}
