import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaSoporte extends StatefulWidget {
  final int idUsuario;
  final String? habitacion;

  PantallaSoporte({required this.idUsuario, this.habitacion});

  @override
  _PantallaSoporteState createState() => _PantallaSoporteState();
}

class _PantallaSoporteState extends State<PantallaSoporte> {
  String? _tipoProblemaKey;
  final _mensajeController = TextEditingController();
  bool _enviando = false;

  final Map<String, String> tiposProblema = {
    'falla_dispositivo': 'Falla en el dispositivo',
    'emergencia': 'Emergencia',
    'otro': 'Otro',
  };

  Future<void> _enviarSoporte() async {
    if (_tipoProblemaKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona un tipo de problema')),
      );
      return;
    }

    setState(() {
      _enviando = true;
    });

    final url = Uri.parse('http://localhost:5000/soporte');

    int habitacionNumero = int.tryParse(
        RegExp(r'\d+').stringMatch(widget.habitacion ?? '') ?? '0'
    ) ?? 0;

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tipo": _tipoProblemaKey,
          "mensaje": _mensajeController.text.trim(),
          "id_usuario": widget.idUsuario,
          "habitacion": habitacionNumero,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte enviado al administrador')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el reporte')),
        );
      }
    } catch (e) {
      print('Error al conectar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo conectar al servidor')),
      );
    } finally {
      setState(() {
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soporte Técnico'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de emergencia', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            DropdownButton<String>(
              isExpanded: true,
              value: _tipoProblemaKey,
              hint: Text('Elige una opción'),
              items: tiposProblema.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoProblemaKey = value!;
                });
              },
            ),
            SizedBox(height: 20),

            Text('Mensaje:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _mensajeController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '',
              ),
            ),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: _enviando ? null : _enviarSoporte,
                icon: Icon(Icons.send),
                label: Text(_enviando ? 'Enviando...' : 'Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
