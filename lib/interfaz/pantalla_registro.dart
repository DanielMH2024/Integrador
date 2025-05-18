import 'package:flutter/material.dart';
//para hacer la peticion Http para enviar datos al backend
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaRegistro extends StatefulWidget {
  @override
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  //este metodo es para enviar los datos al backen
  Future<bool> enviarRegistro(Map<String, String> datosRegistro) async {
    final url = Uri.parse('http://localhost:5000/registro'); // Asegúrate que es la IP de tu PC
  //http://192.168.18.42:5000/registro
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datosRegistro),
      );

      print("Respuesta del servidor: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al enviar registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }


  void _registrarse() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> datos = {
        "nombre": _nombreCtrl.text,
        "apellido": _apellidoCtrl.text,
        "dni": _dniCtrl.text,
        "telefono": _telefonoCtrl.text,
        "direccion": _direccionCtrl.text,
        "correo": _correoCtrl.text,
        "nombre_usuario": _usuarioCtrl.text,
        "contrasena": _passCtrl.text,
      };

      bool exito = await enviarRegistro(datos);

      if (!mounted) return;
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registro exitoso")),
        );
        _formKey.currentState!.reset();
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context); // por si acaso
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al registrar usuario")),
        );
      }
    }
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registro de Usuario'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField('Nombre', Icons.person, _nombreCtrl),
                SizedBox(height: 12),
                _buildTextField('Apellido', Icons.person_outline, _apellidoCtrl),
                SizedBox(height: 12),
                _buildTextField('DNI', Icons.badge, _dniCtrl, keyboardType: TextInputType.number),
                SizedBox(height: 12),
                _buildTextField('Teléfono', Icons.phone, _telefonoCtrl, keyboardType: TextInputType.phone),
                SizedBox(height: 12),
                _buildTextField('Dirección', Icons.home, _direccionCtrl),
                SizedBox(height: 12),
                _buildTextField('Correo', Icons.email, _correoCtrl, keyboardType: TextInputType.emailAddress),
                SizedBox(height: 12),
                _buildTextField('Usuario', Icons.account_circle, _usuarioCtrl),
                SizedBox(height: 12),
                _buildTextField('Contraseña', Icons.lock, _passCtrl, isPassword: true),
                SizedBox(height: 20),
                //boton de registrarse
                ElevatedButton(
                  onPressed: _registrarse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text('Registrarse'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
