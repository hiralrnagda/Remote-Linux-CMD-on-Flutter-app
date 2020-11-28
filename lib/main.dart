import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LinuxCMD(),
    );
  }
}

class LinuxCMD extends StatefulWidget {
  @override
  _LinuxCMDState createState() => _LinuxCMDState();
}

class _LinuxCMDState extends State<LinuxCMD> {
  var response;
  var cmd;
  var fs = FirebaseFirestore.instance;
  var outputsent;
  var cmdsent;
  var outputWidget;
  TextEditingController cmdController = TextEditingController();

  webconnect() async{
    var url = "http://192.168.0.105/cgi-bin/cmd.py?x=$cmd";
    response = await http.get(url);
    await fs.collection("linuxcmdoutput").add({'command' : cmd, 'output': response.body, 'time': DateTime.now()});
    setState(() {
      
    });          
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text(
          'Redhat8 Linux Command Prompt',
          style: TextStyle(color: Colors.black54),
          ),
          backgroundColor: Colors.blue.shade100,
        ),
      body: Column(
        children:[
          TextField(
            controller: cmdController,
            decoration: InputDecoration(hintText: "Enter a linux command",hintStyle: TextStyle(color: Colors.black54,)),
            onChanged: (value){
              cmd= value;
          },),
          SizedBox(height: 10,),
          RaisedButton(
            onPressed: (){
              webconnect();
              cmdController.clear();
          },
          color: Colors.blue.shade500,
            child:Text('Click me for output')),
          SizedBox(height: 10,),
          SingleChildScrollView(
            child: StreamBuilder(
                stream: fs.collection("linuxcmdoutput").orderBy('time',descending: true).snapshots(),
                builder: (context, snapshot) {
                  var msg = snapshot.data.docs;
                  List<Widget> y = [];
                    for (var d in msg) {
                      var command = d.data()['command'];
                      var output = d.data()['output'];
                      var msgWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                        "[root@localhost ~ ]# $command",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black54, fontSize: 17,fontWeight: FontWeight.bold),),
                        Text(
                        "[root@localhost ~ ]# $output",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black54, fontSize: 17,fontWeight: FontWeight.bold),),
                      ],);    
                  y.add(msgWidget);
                    }
                    return  Container(
                        decoration: BoxDecoration(
                                gradient: LinearGradient(
                                      colors: [Colors.blue.shade200, Colors.blue.shade100],
                                ),),
                              padding: EdgeInsets.all(5),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:y),
                              );
                }    
                ),
          ),
          
        ]
      ),
    );
  }
}
