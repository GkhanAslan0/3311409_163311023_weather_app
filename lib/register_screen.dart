import 'package:flutter/material.dart';
import 'package:flutter_weather_app/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorText = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height * 0.25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/login_page.jpg"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hesabınızı Oluşturun",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        shadows: <Shadow>[
                          Shadow(
                            color: Color.fromRGBO(156, 22, 245, 1),
                            blurRadius: 30,
                            offset: Offset(2, 5),
                          ),
                        ],
                      ),
                    ),
                    customSizeBox(),
                    TextField(
                      controller: _emailController,
                      decoration: customInputDecaration("E-Postanızı Giriniz"),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: customInputDecaration("Şifreyi Girin"),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: customInputDecaration("Tekrar Şifreyi Girin"),
                      obscureText: true,
                    ),
                    if (_errorText.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _errorText,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    customSizeBox(),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _register();
                        },
                        child: Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          shadowColor: Colors.grey,
                        ),
                      ),
                    ),
                    customSizeBox(),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Geri Dön",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          shadowColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customSizeBox() => SizedBox(
        height: 20,
      );

  InputDecoration customInputDecaration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _register() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorText = 'Lütfen boş alanları doldurunuz.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorText = 'Girilen şifreler eşleşmiyor.';
      });
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _errorText = 'Bu e-posta adresi zaten kayıtlı.';
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          _errorText = 'Şifre zayıf.';
        });
      } else {
        setState(() {
          _errorText = 'Kayıt olma işlemi sırasında bir hata oluştu.';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'Kayıt olma işlemi sırasında bir hata oluştu.';
      });
    }
  }
}
