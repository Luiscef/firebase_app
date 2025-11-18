import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;
    print('Email: $email, Password: $password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Firebase')),
      body: Padding(
        padding: const EdgeInsets.all(25.0),

        child: Column(
          children: [
            
            const SizedBox(height: 20),
            ClipOval(
              child: const Image(
                image: NetworkImage(
                  'https://preview.redd.it/i-tried-to-remake-walter-white-skateboarding-v0-nvdd0uwwo4ne1.jpg?width=736&format=pjpg&auto=webp&s=d59d1fbdd478865f12c2c4beb76457691925885b',
                ),
                height: 250,
                width: 250,

                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 40),
            Text( 'Inicia sesión para continuar', style: TextStyle(fontSize: 20),),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: 'Email'
                
                ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.golf_course) //es pagina de golf
                ,
                labelText: 'Password'
                ),
              obscureText: true, //pa ponerlo en puntitos
            ),
            const SizedBox(height: 25),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 20),
            Text('------------- O continua con ---------------'),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: const Text('Iniciar sesion con Google')),
          ],
        ),
      ),
    );
  }
}
