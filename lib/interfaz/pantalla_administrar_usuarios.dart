import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:http/http.dart' as http;

class PantallaAdministrarUsuarios extends StatefulWidget {
  @override
  _PantallaAdministrarUsuariosState createState() => _PantallaAdministrarUsuariosState();
}

class _PantallaAdministrarUsuariosState extends State<PantallaAdministrarUsuarios> {
  List usuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final url = Uri.parse('http://localhost:5000/habitaciones_usuarios');
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        setState(() {
          usuarios = data;
          cargando = false;
        });
      } else {
        print('Error en el servidor: ${respuesta.statusCode}');
        setState(() => cargando = false);
      }
    } catch (e) {
      print('Error al obtener datos: $e');
      setState(() => cargando = false);
    }
  }


  Future<bool> eliminarUsuario(dynamic idUsuario) async {
    if (idUsuario == null || idUsuario is! int) {
      print('ID inválido: $idUsuario');
      return false;
    }
    final url = Uri.parse('http://localhost:5000/usuarios/$idUsuario');

    try {
      final response = await http.delete(url);
      print('DELETE status code: ${response.statusCode}');
      print('DELETE response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e, stacktrace) {
      print('Error al eliminar usuario: $e');
      print('Stacktrace: $stacktrace');
      return false;
    }
  }




  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Administrar Usuarios'),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Usuarios'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          return ListTile(
            title: Text('${usuario['nombre']} ${usuario['apellido']}'),
            subtitle: Text(
                'Usuario: ${usuario['nombre_usuario']} - Habitación: ${usuario['habitacion'] ?? "No asignada"}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Contraseña: ${usuario['contrasena_usuario']}'),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    if (usuario['id_usuario'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Usuario sin ID, no se puede eliminar'))
                      );
                      return;
                    }
                    final confirmado = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirmar eliminación'),
                        content: Text('¿Seguro que quieres eliminar a ${usuario['nombre']}?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Eliminar')),
                        ],
                      ),
                    );

                    if (confirmado == true) {
                      bool exito = await eliminarUsuario(usuario['id_usuario']);
                      if (exito) {
                        setState(() {
                          usuarios.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Usuario eliminado')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al eliminar usuario')));
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
