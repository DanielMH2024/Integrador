import 'package:flutter/material.dart';
import 'pantalla_login.dart'; // Asegúrate de importar tu login aquí

class InterfazPrincipal extends StatelessWidget {
  final int idUsuario;
  final String nombre;
  final String rol;

  InterfazPrincipal({
    required this.idUsuario,
    required this.nombre,
    required this.rol,
  });

  void _enviarComando(String comando) {
    print("Comando simulado: $comando");
  }

  void _navegarADispositivo(BuildContext context, String tipoDispositivo) {
    print("Simulación de navegación a: $tipoDispositivo");
  }

  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 Control'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, $nombre',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Center(child: Text('Control por voz', style: TextStyle(fontSize: 20))),
            SizedBox(height: 20),
            Center(
              child: IconButton(
                icon: Icon(Icons.mic, size: 40),
                onPressed: () {
                  print('Simulación de control por voz');
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _enviarComando('encender'),
                  child: Text('Encendido'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _enviarComando('apagar'),
                  child: Text('Apagado'),
                ),
              ],
            ),
            SizedBox(height: 40),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.toys, size: 30),
                      onPressed: () => _navegarADispositivo(context, 'ventilador'),
                    ),
                    Text('Ventilador'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.lock, size: 30),
                      onPressed: () => _navegarADispositivo(context, 'cerradura'),
                    ),
                    Text('Cerradura'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.lightbulb_outline, size: 30),
                      onPressed: () => _navegarADispositivo(context, 'luz'),
                    ),
                    Text('Luz'),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
