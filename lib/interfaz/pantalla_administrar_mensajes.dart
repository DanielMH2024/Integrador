import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';

class PantallaAdministrarMensajes extends StatefulWidget {
  @override
  _PantallaAdministrarMensajesState createState() =>
      _PantallaAdministrarMensajesState();
}

class _PantallaAdministrarMensajesState extends State<PantallaAdministrarMensajes> {
  List mensajes = [];
  bool cargando = true;
  String error = '';
  final String backendUrl = 'http://localhost:5000'; // Cambiar si estás en móvil

  @override
  void initState() {
    super.initState();
    cargarMensajes();
  }

  Future<void> cargarMensajes() async {
    setState(() {
      cargando = true;
      error = '';
    });

    try {
      final res = await http.get(Uri.parse('$backendUrl/soporte'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          mensajes = data;
          cargando = false;
        });
      } else {
        setState(() {
          error = 'Error del servidor: ${res.statusCode}';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        cargando = false;
      });
    }
  }

  Future<void> marcarComoAtendido(int idSoporte, int index) async {
    try {
      final res = await http.delete(Uri.parse('$backendUrl/soporte/$idSoporte'));

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mensaje atendido y eliminado')),
        );
        Navigator.pop(context, true); // Recarga pantalla anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  String formatearFecha(String fechaOriginal) {
    try {
      final fecha = DateTime.parse(fechaOriginal);
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toLocal());
    } catch (_) {
      try {
        final fecha = HttpDate.parse(fechaOriginal);
        return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toLocal());
      } catch (_) {
        return fechaOriginal;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Mensajes'),
        backgroundColor: Colors.blue,
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text('Error: $error'))
          : mensajes.isEmpty
          ? Center(child: Text('No hay mensajes'))
          : ListView.builder(
        itemCount: mensajes.length,
        itemBuilder: (context, index) {
          final msg = mensajes[index];
          final nombre = msg['nombre_persona'] ?? '---';
          final habitacion = msg['habitacion'] ?? '---';
          final tipo = msg['tipo_problema'] ?? '---';
          final mensaje = msg['mensaje'] ?? '---';
          final fecha = msg['fecha'] ?? '';
          final idSoporte = msg['id_soporte'];

          return ListTile(
            title: Text('$nombre'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Habitación: $habitacion'),
                Text('Tipo: $tipo'),
                Text('Mensaje: $mensaje'),
                Text('Fecha: ${formatearFecha(fecha)}'),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Marcar como atendido',
              onPressed: () => marcarComoAtendido(idSoporte, index),
            ),
          );
        },
      ),
    );
  }
}
