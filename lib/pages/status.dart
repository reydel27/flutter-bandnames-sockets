import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    //socketService.socket.emit(event);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ServerStatus: ${ socketService.serverStatus }')
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.message ),
        onPressed: () {
          socketService.socket.emit('send-message', {'name': 'Flutter','message': 'Message from flutter'});
        },
      ),
    );
  }
}