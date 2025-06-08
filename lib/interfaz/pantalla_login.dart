import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'pantalla_admin.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class PantallaLogin extends StatefulWidget {
  @override
  _PantallaLoginState createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final String usuario = _usuarioCtrl.text.trim();
      final String contrasena = _passCtrl.text.trim();

      // Acceso fijo para el admin pueba
      if (usuario == 'admin' && contrasena == '1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InterfazAdmin(
              idUsuario: 0,
              nombre: 'Administrador',
              rol: 'admin',
            ),
          ),
        );
        return;
      }

      // Validación real para usuarios comunes
      final url = Uri.parse('http://localhost:5000/login'); //ip real
      // la ip 192.168.18.42 para que se comunique con telefono
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nombre_usuario': usuario,
            'contrasena': contrasena,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final int idUsuario = data['id_usuario'];
          final String nombre = data['nombre'];
          final String rol = data['rol'];

          if (rol == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InterfazAdmin(
                  idUsuario: idUsuario,
                  nombre: nombre,
                  rol: rol,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InterfazPrincipal(
                  idUsuario: idUsuario,
                  nombre: nombre,
                  rol: rol,
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario o contraseña incorrectos')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con el servidor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  'assets/usuario.png',
                  height: 150,
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _usuarioCtrl,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu usuario';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Iniciar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/registro'),
                  child: Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
