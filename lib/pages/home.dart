import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Bon Jovi', votes: 0),
    Band(id: '3', name: 'Rammstein', votes: 4),
    Band(id: '4', name: 'Marron 5', votes: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Band Names', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: ( context, i ) => _bandTile( bands[i] )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon( Icons.add),
          elevation: 1,
          onPressed: addNewBand
        ),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( DismissDirection direction ) {
        // borrar item
        print('direction: $direction');
        print('id: ${ band.id }');
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
          print( band.name );
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
      this.bands.add(new Band(id: DateTime.now().toString(),name: name, votes: 0));
      setState(() {});
    }
    
    Navigator.pop( context );
  }
}