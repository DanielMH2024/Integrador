import 'dart:io';
import 'package:flutter/material.dart';
import 'package:integrador_app/interfaz/pantalla_administrar_mensajes.dart';
import 'package:integrador_app/interfaz/pantalla_administrar_usuarios.dart';
import 'pantalla_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';


class InterfazAdmin extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String rol;

  InterfazAdmin({
    required this.idUsuario,
    required this.nombre,
    required this.rol,
  });

  @override
  _InterfazAdminState createState() => _InterfazAdminState();
}

class _InterfazAdminState extends State<InterfazAdmin> {
  List<dynamic> habitacionesUsuarios = [];
  bool cargando = false;
  String errorCarga = '';

  List<dynamic> mensajesAtencion = []; // Declarar esta lista aquí
  bool cargandoMensajes = false;
  String errorMensajes = '';

  // Controladores de texto
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _habitacionCtrl = TextEditingController();

  String rolSeleccionado = 'usuario';
  final List<String> roles = ['usuario', 'admin'];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _cargarMensajes();
  }

  //nuevo a gregado
  void _cargarMensajes() async {
    setState(() {
      cargandoMensajes = true;
      errorMensajes = '';
    });

    try {
      final mensajes = await fetchMensajesProblemas();
      print('Mensajes recibidos: $mensajes'); // <- Aquí
      setState(() {
        mensajesAtencion = List.from(mensajes);
        mensajesAtencion.sort((a, b) =>
            (a['fecha'] ?? '').compareTo(b['fecha'] ?? ''));
      });
    } catch (e) {
      setState(() {
        errorMensajes = e.toString();
      });
    } finally {
      setState(() {
        cargandoMensajes = false;
      });
    }
  }

  void _cargarDatos() async {
    setState(() {
      cargando = true;
      errorCarga = '';
    });

    try {
      final datos = await fetchHabitacionesUsuarios();
      setState(() {
        habitacionesUsuarios = datos;
      });
    } catch (e) {
      setState(() {
        errorCarga = e.toString();
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType? keyboardType,
        bool obscureText = false,
      ]) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            prefixIcon: Icon(icon),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Administrador - ${widget.nombre}'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PantallaLogin()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crear Nueva Cuenta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildTextField(_nombreCtrl, 'Nombre', Icons.person),
            _buildTextField(_apellidoCtrl, 'Apellido', Icons.person_outline),
            _buildTextField(_dniCtrl, 'DNI', Icons.badge, TextInputType.number),
            _buildTextField(_telefonoCtrl, 'Teléfono', Icons.phone,
                TextInputType.phone),
            _buildTextField(_direccionCtrl, 'Dirección', Icons.home),
            _buildTextField(_correoCtrl, 'Correo electrónico', Icons.email,
                TextInputType.emailAddress),
            _buildTextField(_usuarioCtrl, 'Usuario', Icons.account_circle),
            _buildTextField(_passCtrl, 'Contraseña', Icons.lock, null, true),
            _buildTextField(
                _habitacionCtrl, 'Habitación asignada', Icons.meeting_room),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: rolSeleccionado,
              decoration: InputDecoration(
                  labelText: 'Rol', border: OutlineInputBorder()),
              items:
              roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (value) {
                setState(() {
                  rolSeleccionado = value ?? 'usuario';
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (_nombreCtrl.text.isEmpty ||
                    _apellidoCtrl.text.isEmpty ||
                    _dniCtrl.text.isEmpty ||
                    _telefonoCtrl.text.isEmpty ||
                    _direccionCtrl.text.isEmpty ||
                    _correoCtrl.text.isEmpty ||
                    _usuarioCtrl.text.isEmpty ||
                    _passCtrl.text.isEmpty ||
                    _habitacionCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rellene todos los campos')),
                  );
                  return;
                }

                Map<String, String> datos = {
                  "nombre": _nombreCtrl.text,
                  "apellido": _apellidoCtrl.text,
                  "dni": _dniCtrl.text,
                  "telefono": _telefonoCtrl.text,
                  "direccion": _direccionCtrl.text,
                  "correo": _correoCtrl.text,
                  "nombre_usuario": _usuarioCtrl.text,
                  "contrasena": _passCtrl.text,
                  "rol": rolSeleccionado,
                  "habitacion": _habitacionCtrl.text,
                };

                final resultado = await crearUsuario(datos);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resultado["mensaje"])),
                );

                if (resultado["exito"]) {
                  _nombreCtrl.clear();
                  _apellidoCtrl.clear();
                  _dniCtrl.clear();
                  _telefonoCtrl.clear();
                  _direccionCtrl.clear();
                  _correoCtrl.clear();
                  _usuarioCtrl.clear();
                  _passCtrl.clear();
                  _habitacionCtrl.clear();
                  setState(() {
                    rolSeleccionado = 'usuario';
                  });
                  _cargarDatos(); //actualiza el historial automatico
                }
              },
              child: Text('Crear Cuenta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            Divider(height: 40),
            Text('Historial de Comandos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(child: Text('')), // Aquí deberías poner el historial
            ),
            Divider(height: 40),
            Text('Habitaciones y Usuarios Asignados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {
                _cargarDatos();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaAdministrarUsuarios(),
                  ),
                );
              },
              icon: Icon(Icons.manage_accounts),
              label: Text('Administrar Usuarios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            Container(
              height: 200,
              color: Colors.grey[200],
              child: cargando
                  ? Center(child: CircularProgressIndicator())
                  : errorCarga.isNotEmpty
                  ? Center(child: Text('Error: $errorCarga'))
                  : ListView.builder(
                itemCount: habitacionesUsuarios.length,
                itemBuilder: (context, index) {
                  final item = habitacionesUsuarios[index];
                  return ListTile(
                    title: Text('${item['nombre']} ${item['apellido']}'),
                    subtitle: Text(
                      'Usuario: ${item['nombre_usuario']}\n'
                          'Contraseña: ${item['contrasena_usuario']}\n'
                          'Habitación: ${item['habitacion']}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),

            Divider(height: 40),
            Text('Mensajes de Atención',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PantallaAdministrarMensajes()),
                );

                if (resultado == true) {
                  _cargarMensajes();
                }
              },
              icon: Icon(Icons.message),
              label: Text('Administrar Mensajes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            Container(
              height: 200,
              color: Colors.grey[200],
              child: cargandoMensajes
                  ? Center(child: CircularProgressIndicator())
                  : errorMensajes.isNotEmpty
                  ? Center(child: Text('Error: $errorMensajes'))
                  : mensajesAtencion.isEmpty
                  ? Center(child: Text('No hay mensajes'))
                  : ListView.builder(
                itemCount: mensajesAtencion.length,
                itemBuilder: (context, index) {
                  final msg = mensajesAtencion[index];

                  final habitacion = msg['habitacion'] ?? 'Desconocida';
                  final nombreCompleto = msg['nombre_persona'] ?? 'Desconocido';
                  final tipoProblema = msg['tipo_problema'] ?? 'Sin tipo';
                  final mensaje = msg['mensaje'] ?? 'Sin mensaje';
                  final fecha = msg['fecha'] ?? '';
                  final fechaFormateada = fecha.isNotEmpty
                      ? formatearFecha(fecha)
                      : 'sin fecha';

                  return ListTile(
                    title: Text(nombreCompleto),
                    subtitle: Text(
                      'Habitación: $habitacion\n'
                          'Tipo: $tipoProblema\n'
                          'Mensaje: $mensaje\n'
                          'Fecha: $fechaFormateada',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// creacion de usuario
Future<Map<String, dynamic>> crearUsuario(Map<String, String> datos) async {
  final url = Uri.parse('http://localhost:5000/registro');

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(datos),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        "exito": true,
        "mensaje": body["mensaje"] ?? "Usuario creado correctamente"
      };
    } else {
      return {
        "exito": false,
        "mensaje": body["error"] ?? "Error desconocido"
      };
    }
  } catch (e) {
    return {
      "exito": false,
      "mensaje": "Error de conexión: $e"
    };
  }
}

// Funcion para la lista de usuarios y habitaciones
Future<List<dynamic>> fetchHabitacionesUsuarios() async {
  final url = Uri.parse('http://localhost:5000/habitaciones_usuarios'); // Cambia por tu endpoint real

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

// Función para traer mensajes de problemas o atención
Future<List<dynamic>> fetchMensajesProblemas() async {
  final url = Uri.parse('http://localhost:5000/soporte'); // Cambia por tu endpoint real

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar mensajes');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

//cambio de fecha
String formatearFecha(String fechaOriginal) {
  try {
    DateTime fechaParseada = HttpDate.parse(fechaOriginal);
    final formatoDeseado = DateFormat('dd/MM/yyyy HH:mm');
    return formatoDeseado.format(fechaParseada);
  } catch (e) {
    return fechaOriginal;
  }
}