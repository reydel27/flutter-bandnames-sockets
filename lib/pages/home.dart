import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];
  
  @override
  void initState() { 
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands( dynamic payload ){
      this.bands = (payload as List)
        .map( (band) => Band.fromMap(band) )
        .toList();
      
        setState(() {});
  }

  @override
  void dispose(){
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Band Names', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: ( socketService.serverStatus == ServerStatus.Online ) ? 
                Icon(Icons.offline_bolt, color: Colors.green[300]) :
                Icon(Icons.offline_bolt, color: Colors.red[300])
            )
          ],
          leading: FlatButton(
            onPressed: addNewBand ,
            child: Icon(Icons.add),  
          )
        ),
        body: Column(
          children: [
            _showChart(),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: ( context, i ) => _bandTile( bands[i] )
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( DismissDirection direction ) {
        socketService.socket.emit('delete-band', { 'id': band.id });
        //setState(() {});
      },
      background: Container(
        padding: EdgeInsets.only( left: 10.0 ),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete', style: TextStyle( color: Colors.white),),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2)),
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20) ),
        onTap: () {

          socketService.socket.emit('votes', { 'id': band.id });

        },
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();

    if( Platform.isAndroid ){
      showDialog(
        context: context,
        builder: ( context ) {
          return AlertDialog(
            title: Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text )
              )
            ],
          );
        }
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ){
        return CupertinoAlertDialog(
          title: Text('New band name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList( textController.text )
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop( context )
            ),            
          ],
        );
      }
    );
  }

  void addBandToList( String name){

    if( name.length > 1 ){
    final socketService = Provider.of<SocketService>(context, listen: false);  

      socketService.socket.emit('add-band', { 'name': name });    
      setState(() {});
    }
    
    Navigator.pop( context );
  }
  // Mostrar grafica
  Widget _showChart(){

      
      Map<String, double> dataMap = new Map();

      bands.forEach((band) {
        dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
      });

      return Container(
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        height: 200,
        child:  dataMap.isNotEmpty ? PieChart(
          dataMap: dataMap,
          chartType: ChartType.ring,
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
        ),
        ) : Center(child: CircularProgressIndicator())
      );
  }

}