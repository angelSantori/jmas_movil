import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_movil/controllers/users_controller.dart';
import 'package:jmas_movil/general/home_screen.dart';
import 'package:jmas_movil/widgets/mensajes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UsersController _usersController = UsersController();

  final _accesUser = TextEditingController();
  final _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final success = await _usersController.loginUser(
          _accesUser.text,
          _password.text,
          context,
        );

        if (success) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ));
        } else {
          showAdvertence(
              context, 'Usuario o contraseña incorrectos. Inténtalo de nuevo.');
        }
      } catch (e) {
        showAdvertence(context, 'Error al inicar sesión: $e');
      }
    } else {
      showAdvertence(context, 'Por favor introduce usuario y contraseña.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Bienvenido'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildFormRow(
                  label: 'Acceso',
                  child: TextFormField(
                    controller: _accesUser,
                    decoration:
                        const InputDecoration(labelText: 'Acceso de usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce acceso';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s'))
                    ],
                    obscureText: true,
                  ),
                ),

                const SizedBox(height: 20),

                //Pass
                buildFormRow(
                  label: 'Contrasela',
                  child: TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                        labelText: 'Contraseña de usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contraseña requerida';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s'))
                    ],
                    obscureText: true,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
