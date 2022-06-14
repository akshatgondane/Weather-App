import 'dart:convert';

import 'package:flutter/material.dart';
import '../util/utils.dart' as util;
import 'package:http/http.dart' as http;
class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String cityEntered = "";

  Future goToNextScreen(BuildContext context) async
  {
    Map results = await Navigator.of(context).push(
      new MaterialPageRoute<dynamic>(builder: (BuildContext context)
      {
        return new ChangeCity();
      })
    );

    if(results != null && results.containsKey('enter'))
      {
        setState(() {
          cityEntered = results['enter'];
          print(results['enter']);
        });

      }
    else
      {
        cityEntered = util.defaultCity;
      }


  }




  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Klimatic"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          new IconButton(onPressed:()=>goToNextScreen(context), icon: new Icon(Icons.menu))
        ],
      ),
      body: new Stack(
        children: [
          new Center(
            child: Image.asset('images/umbrella.png', fit: BoxFit.fill, width: 490.0,),
          ),

          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: new Text('${cityEntered.length == 0? util.defaultCity : cityEntered}', style: cityStyle()),
          ),

          new Container(
            alignment: Alignment.center,
            child: new Image.asset("images/light_rain.png"),
          ),

          new Container(
            margin: const EdgeInsets.fromLTRB(30.0, 310.0, 0.0, 0.0),
            child: updateTempWidget("${cityEntered}")
          )
        ],
      )
    );
  }

  Future<Map> getWeather(String appID, String city) async
  {
    var apiUrl = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${util.appID}&units=imperial");
    http.Response response = await http.get(apiUrl);
    return jsonDecode(response.body);
  }

  Widget updateTempWidget(String city)
  {
    print("City received in updateTempWidget: $city");
    return new FutureBuilder(
      future: getWeather(util.appID, city.length == 0? util.defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot)
      {
        if(snapshot.hasData)
          {
            Map? content = snapshot.data;
            return new Container(
              child: new Column(
                children: [
                  new ListTile(
                    title: new Text(content!['main']['temp'].toString(), style: tempStyle(),),
                  )
                ],
              ),
            );
          }
        else if(snapshot.hasError)
          {
            return new Container(
              child: new Column(
                children: [
                  new ListTile(
                    title: new Text("${snapshot.error}"),
                  )
                ],
              ),
            );
          }
        else
          {
            return const Center(child: CircularProgressIndicator());
          }


      }, );
  }
}

TextStyle cityStyle()
{
  return new TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic
  );
}

TextStyle tempStyle()
{
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.9
  );
}

class ChangeCity extends StatefulWidget {
  @override
  _ChangeCityState createState() => _ChangeCityState();
}

class _ChangeCityState extends State<ChangeCity> {
  @override
  var cityFieldController = new TextEditingController();
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Change City"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: new Stack(
        children: [
          new Center(
            child: new Image.asset('images/white_snow.png', width: 490.0, height: 1200.0, fit: BoxFit.fill,),
          ),

          new ListView(
            children: [
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: "Enter City"
                  ),
                  controller: cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),

              new ListTile(
                title: new ElevatedButton(onPressed: ()
                  {
                    Navigator.pop(context,
                    {
                      'enter': cityFieldController.text.toString()
                    });
                  }, child: new Text('Get Weather'), ),
              )
            ],
          )
        ],
      ),
    );
  }
}


