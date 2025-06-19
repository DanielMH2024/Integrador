import 'package:flutter/material.dart';
import 'package:integrador_app/interfaz/pantalla_soporte.dart';
import 'pantalla_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class InterfazPrincipal extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String rol;

  InterfazPrincipal({
    required this.idUsuario,
    required this.nombre,
    required this.rol,
  });

  @override
  _InterfazPrincipalState createState() => _InterfazPrincipalState();


}

class _InterfazPrincipalState extends State<InterfazPrincipal> {
  String dispositivoActivo = ''; // 'foco1', 'cerradura', 'foco2'
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _textoReconocido = '';

  @override
  void initState(){
    super.initState();
    _speech = stt.SpeechToText();
  }


  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaLogin()),
    );
  }

  void _iniciarEscucha() async {
    if (!_isListening) {
      bool disponible = await _speech.initialize(
        onStatus: (estado) => print('Estado: $estado'),
        onError: (error) => print('Error: $error'),
      );

      if (disponible) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (resultado) {
            setState(() {
              _textoReconocido = resultado.recognizedWords.toLowerCase();
            });

            print('Reconocido: $_textoReconocido');

            // Acciones según la frase
            if (_textoReconocido.contains('encender foco uno')) {
              enviarComandoFoco('1', 'encender');
            } else if (_textoReconocido.contains('apagar foco uno')) {
              enviarComandoFoco('1', 'apagar');
            } else if (_textoReconocido.contains('encender foco dos')) {
              enviarComandoFoco('3', 'encender');
            } else if (_textoReconocido.contains('apagar foco dos')) {
              enviarComandoFoco('3', 'apagar');
            } else if (_textoReconocido.contains('abrir cerradura')) {
              enviarComandoCerradura('2', 'abrir');
            } else if (_textoReconocido.contains('cerrar cerradura')) {
              enviarComandoCerradura('2', 'cerrar');
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }





  Future<void> enviarComandoFoco(String dispositivoId, String accion) async {
    final url = Uri.parse('http://localhost:5000/api/dispositivo/foco');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dispositivo_id': int.parse(dispositivoId),
          'accion': accion,
          'id_usuario': widget.idUsuario,
          'id_habitacion': 1,
        }),
      );
      if (response.statusCode == 200) {
        print('Comando foco enviado: $accion');
      } else {
        print('Error al enviar comando foco: ${response.statusCode}');
        print('Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión (foco): $e');
    }
  }

  Future<void> enviarComandoCerradura(String dispositivoId, String accion) async {
    final url = Uri.parse('http://localhost:5000/api/dispositivo/cerradura');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dispositivo_id': int.parse(dispositivoId),
          'accion': accion,
          'id_usuario': widget.idUsuario,
          'id_habitacion': 1,
        }),
      );
      if (response.statusCode == 200) {
        print('Cerradura $accion correctamente');
      } else {
        print('Error cerradura: ${response.statusCode}');
        print('Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión (cerradura): $e');
    }
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Bienvenido, ${widget.nombre}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              Center(child: Text('Control por voz', style: TextStyle(fontSize: 20))),
              SizedBox(height: 20),
              Center(
                child: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 40, color: Colors.redAccent),
                  onPressed: _iniciarEscucha,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  _textoReconocido,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),


              SizedBox(height: 20),
              Center(
                child: Text(
                  dispositivoActivo == 'foco1'
                      ? 'Foco 1'
                      : (dispositivoActivo == 'foco2' ? 'Foco 2': 'Control Focos'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                  onPressed: (dispositivoActivo == 'foco1' || dispositivoActivo == 'foco2')
                        ? () => enviarComandoFoco(
                        dispositivoActivo == 'foco1' ? '1' : '3',
                        'encender')
                        : null,
                    child: Text('Encender'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: (dispositivoActivo == 'foco1' || dispositivoActivo == 'foco2')
                        ? () => enviarComandoFoco(
                        dispositivoActivo == 'foco1' ? '1' : '3', 'apagar')
                        : null,
                    child: Text('Apagar'),
                  ),
                ],
              ),


              const SizedBox(height: 40),
              Center(child: Text('Control de Cerradura', style: TextStyle(fontSize: 18))),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: dispositivoActivo == 'cerradura'
                        ? () => enviarComandoCerradura('2', 'abrir')
                        : null,
                    child: Text('Abrir'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: dispositivoActivo == 'cerradura'
                        ? () => enviarComandoCerradura('2', 'cerrar')
                        : null,
                    child: Text('Cerrar'),
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
                        icon: Icon(Icons.lightbulb_outline, size: 30,
                        color: dispositivoActivo == 'foco1' ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            dispositivoActivo = 'foco1';
                          });
                          print("Activado: Foco 1");
                        },
                      ),
                      Text('Foco 1'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.lock, size: 30,
                        color: dispositivoActivo == 'cerradura' ? Colors.blueAccent : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            dispositivoActivo = 'cerradura';
                          });
                          print("Activado: Cerradura");
                        },
                      ),
                      Text('Cerradura'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.lightbulb, size: 30,
                        color: dispositivoActivo == 'foco2' ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            dispositivoActivo = 'foco2';
                          });
                          print("Activado: Foco 2");
                        },
                      ),
                      Text('Foco 2'),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaSoporte(idUsuario: widget.idUsuario),
                      ),
                    );
                  },
                  icon: Icon(Icons.support_agent),
                  label: Text('Soporte Técnico'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

