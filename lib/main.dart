import 'package:flutter/material.dart';
import 'interfaz/pantalla_login.dart'; //ruta de pantalla login
import 'interfaz/pantalla_registro.dart'; //ruta de pantalla registro

void main() {
  runApp(TecnoVidaApp());

}

class TecnoVidaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TecnoVida',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white, // fondo blanco simple
      ),
      home: PantallaLogin(),
      routes: {
        '/registro': (context) => PantallaRegistro(),
      },
    );
  }
}
