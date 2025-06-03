import 'package:flutter/material.dart';

class PantallaSoporte extends StatefulWidget {
  @override
  _PantallaSoporteState createState() => _PantallaSoporteState();
}

class _PantallaSoporteState extends State<PantallaSoporte> {
  String? _tipoProblema;
  final _mensajeController = TextEditingController();

  void _enviarSoporte() {
    if (_tipoProblema == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un tipo de problema')),
      );
      return;
    }

    String mensaje = _mensajeController.text.trim();
    print('Soporte enviado: $_tipoProblema - Mensaje: $mensaje');

    // Aquí deberías enviar el reporte a la base de datos, o backend
    // Puedes asociarlo con el idUsuario y la habitación si lo deseas

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reporte enviado al administrador')),
    );

    Navigator.pop(context); // Volver a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soporte Técnico'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingrese el tipo de emergencia', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: _tipoProblema,
              hint: Text('Elige una opción'),
              items: [
                'Falla en el dispositivo',
                'Emergencia',
                'Otro',
              ].map((String valor) {
                return DropdownMenuItem<String>(
                  value: valor,
                  child: Text(valor),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoProblema = value!;
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
                onPressed: _enviarSoporte,
                icon: Icon(Icons.send),
                label: Text('Enviar'),
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
