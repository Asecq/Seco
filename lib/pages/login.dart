import 'dart:convert';
import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:seco/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/connect.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() =>  _LoginPageState();
}
String token1 = "";
late SharedPreferences prefs;
String erorr  = "";
late String token;
TextEditingController _phone =  TextEditingController();
TextEditingController _password =  TextEditingController();
class _LoginPageState extends State<LoginPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
        () async {
          await Firebase.initializeApp();
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );


          if (Platform.isAndroid) {
            FirebaseMessaging.instance.getToken().then((_token) {
              print('[getToken] token: $_token');
              token1 = _token!;
            }).catchError((onError) {
              print('[getToken] onError: $onError');
            });
          }else if(Platform.isIOS){
            token1 = (await FirebaseMessaging.instance.getToken())!;
          }

          // _in


          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
            token1 = newToken;
          });

          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
            // Save newToken
            print('Token: $newToken');

          });
      prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token') ?? "";
      print(token);
      if(prefs.getString("token") !=   "" && prefs.getString("token") != null){
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => const Home(),
          ),
              (Route route) => false,
        );

      }else{
        //Navigator.pop(context);
      }

    }();



  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final logo = Hero(
      tag: 'hero',
      child: Image.asset('assets/images/logo.png' ,  height: size.height * 0.15,),
    );
    final title = Center(child: Text(
      'شركة سيكو للتوصيل السريع',
      style: TextStyle(color: Colors.black , fontSize: size.width * 0.04),
    ),);

    final phone = TextFormField(
      controller: _phone,
      keyboardType: TextInputType.phone,
      autofocus: false,

      decoration: InputDecoration(

        hintText: 'رقم الهاتف',
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: _password,
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,

      decoration: InputDecoration(

        hintText: 'كلمة السر',
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton =  SizedBox(
    width: size.width / 1.5
    ,
    child: ElevatedButton(

        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(
                Colors.blue),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(

                RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.blue)
                )
            )
        ),


      onPressed: () async{
        if(_phone.text.isNotEmpty && _password.text.isNotEmpty){
          CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
          );
          try {
            final result = await InternetAddress.lookup('example.com');
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
              print('connected');
              login();
            }
          } on SocketException catch (_) {
            Navigator.pop(context);
            const snackBar = SnackBar(
              content: Text('ليس لديك اتصال في الشبكة'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

        }else{
          setState(() {
            erorr ="الرجاء كتابة كل المعلومات";
          });

        }
      },
      child: Text('تسجيل دخول', style: TextStyle(color: Colors.white , fontSize: size.width  * 0.04)),
    ),);

    final error = Text(erorr
      , style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.04,
          color: Colors.redAccent
      ),
    );
    final forgotLabel = FlatButton(
      child: Text(
        'ليس لديك حساب ؟',
        style: TextStyle(color: Colors.black54 , fontSize: size.width * 0.035),
      ),
      onPressed: () {},
    );
    final forgotCopy = FlatButton(
      child: const Text(
        'Dev By ALi Mohammed',
        style:  TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(child: Column(
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: logo,),
            const SizedBox(height: 8.0),
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: title,),
            const SizedBox(height: 40.0),
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: phone,),
            const SizedBox(height: 15.0),
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: password,),
            const SizedBox(height: 24.0),
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: loginButton,),
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: error,),
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: forgotLabel,),
            const SizedBox(height: 24.0),
            Padding(padding: const EdgeInsets.only(left: 24.0, right: 24.0),child: forgotCopy,),

          ],
        ),),
      ),
    ));


  }

  void login() async {
    var url1 = Uri.parse(
        Apis.Api  + 'login.php?phone='+ _phone.text.toString() + '&password=' + _password.text.toString()
    );
    http.Response response = await http.get(url1);
    var data = json.decode(response.body);
    print(data);
    Navigator.pop(context);
    if (data.toString().contains("token")) {

      if(data["token"] !=  "none"){
        if(data["token"].toString().trim() != "" &&  data["token"].toString().trim() != "none"){
          SharedPreferences sharedPreferences = await  SharedPreferences.getInstance();
          sharedPreferences.setString("token", data["token"]);
          sharedPreferences.setString("type", data["type"]);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => Home(),
            ),
                (Route route) => false,
          );
        }

      }
    }else if (data.toString().contains("Logined")) {

      setState(() {

        erorr = "الحساب قيد تسجيل الدخول";
      });

    }else{
      setState(() {


        erorr = "رقم الهاتف او كلمة السر غير صحيحة";
      });
    }

  }
}
