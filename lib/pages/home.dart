import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:http/http.dart' as http;
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:seco/pages/history_done.dart';
import 'package:seco/pages/login.dart';
import 'package:seco/subPages/back.dart';
import 'package:seco/subPages/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/connect.dart';
import '../subPages/done.dart';
import 'history_back.dart';

  List items = [];
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}
late TabController _controller;

  int _currentIndex = 1;

class _HomeState extends State<Home>  with SingleTickerProviderStateMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    _controller = TabController(length: 4, vsync: this);
    _controller.addListener(_handleTabSelection);
  }

  _handleTabSelection() {
    setState(() {
      _currentIndex = _controller.index;
    });
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final drawerItems = ListView(

      children: <Widget>[
        const SizedBox(
          height: 70,
        ),
        DrawerHeader(


          child: Column(
            children: [
              Image.asset("assets/images/logo.png" , height: size.height / 10,),
              const SizedBox(height: 10,),
              Text((items.isNotEmpty)? items[0]['username'] : "...", textAlign: TextAlign.center,style: TextStyle(
                  fontSize: size.width / 20,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold
              ),),
              const SizedBox(
                height: 5,
              ),


            ],
          ),


        ),
         const SizedBox(
          height: 5,
        ),

         ListTile(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => history_done()),
            );
          },

          title:   const Text("ارشيف الطلبات الواصلة" , style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold
          ),),
          leading:  const Icon(Icons.check_box , color: Colors.blueAccent,),
        ),
         ListTile(
           onTap: (){
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => history_back()),
             );
           },
          title:   const Text("ارشيف الطلبات الراجعة" , style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold
          ),),
          leading:  const Icon(Icons.not_interested_sharp , color: Colors.blueAccent,),
        ),
        const ListTile(
          title:   Text("التبليغات" , style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold
          ),),
          leading:  Icon(Icons.notifications , color: Colors.blueAccent,),
        ),

        const ListTile(
          title:   Text("اتصل بنا" , style: TextStyle(

              color: Colors.blueAccent,
              fontWeight: FontWeight.bold
          ),),
          leading:  Icon(Icons.call , color: Colors.blueAccent,),
        ),
        const ListTile(
          title:   Text("عن التطبيق" , style: TextStyle(

              color: Colors.blueAccent,
              fontWeight: FontWeight.bold
          ),),

          leading: Icon(Icons.info , color: Colors.blueAccent,),
        ),
        ListTile(
          onTap: (){
            logout();

          },
          title:  const Text("تسجيل خروج" , style:  TextStyle(

              color: Colors.blueAccent,
              fontWeight: FontWeight.bold
          ),),
          leading: const Icon(Icons.logout , color: Colors.blueAccent,),
        ),
        const SizedBox(height: 120,),
        const Center(child: Text("v 1.0" , style: TextStyle(
            fontSize: 18,

            color: Colors.black45,
            fontWeight: FontWeight.bold
        ),),)
      ],
    );
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: size.height / 10,

        title: Container(

            height: 60.0,
            width: 60.0,
            padding: const EdgeInsets.all(2),
            decoration:  BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
              border: Border.all(color: Colors.white30),
            ),
            child: Image.asset("assets/images/logo.png" , height: size.height / 20,)
        ),
      ),
      drawer: Drawer(
        child: drawerItems,
      ),
      body: TabBarView(
        controller: _controller,
        children: const <Widget>[
          statces(),
          loading(),
          done(),
          back(),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        controller: _controller,
        disableDefaultTabController: true,
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.insert_chart , title: "الاحصائيات"),
          TabItem(icon: Icons.access_time , title: "قيد التسليم"  " (21) "),
          TabItem(icon: Icons.check_circle , title: "واصل"  " (19) "),
          TabItem(icon: Icons.not_interested_sharp , title: "راجع" " (2) "),
        ],
        initialActiveIndex: _controller.index,
        onTap: (int i) {
          setState(() {
            _currentIndex = i;

          });
        },
      ),

          ),
    );



  }
  late SharedPreferences prefs;
  late String token9;
  void logout() async{
    prefs = await SharedPreferences.getInstance();
    token9 = prefs.getString('token') ?? "";
    var url = Uri.parse(Apis.Api + 'logout.php?token=' + token9);
    http.Response response = await http.get(url);
    var data = json.decode(response.body);
    if (data.toString().contains("done")) {
      SharedPreferences sharedPreferences = await  SharedPreferences.getInstance();
      sharedPreferences.setString("token","");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    }

  }

}
class statces extends StatefulWidget {
  const statces({Key? key}) : super(key: key);

  @override
  _statcesState createState() => _statcesState();
}

class _statcesState extends State<statces> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await CoolAlert.show(
          barrierDismissible: false,
          context: context,
          type: CoolAlertType.loading,
          text: "جاري التحميل"
      );

    });
  }
  late SharedPreferences prefs;
  late String token1;
  Future getItems() async {

    prefs = await SharedPreferences.getInstance();
    token1 = prefs.getString('token') ?? "";
    var url = Uri.parse(Apis.Api + 'index.php?token=' + token1);

    http.Response response = await http.get(url);
    var  data = json.decode(response.body);
    print(data);
    setState(() {

      items = data;

    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var item1 =  InkWell(
      onTap: (){

    _controller.animateTo(1);
      },
      child: Padding(padding:  EdgeInsets.all(10)
        ,child: Container(
          padding: EdgeInsets.all(15.0),
          decoration: const BoxDecoration(

              color: Colors.black12,
              borderRadius:  BorderRadius.all(
                  Radius.circular(10.0))
          ),
          child: Column(
            children:  [

              const Text("طلبات قيد التسليم" , style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children:  [
                  Text((items.isNotEmpty)? "العدد : " + items[0]['loading'].toString()  : "...." ,style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),),
                  Text((items.isNotEmpty)? "المبلغ الصافي : " + items[0]['price_loading'].toString() + " د.ع "  : "...." , style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),),

                ],
              ),




            ],
          ),

        ),

      ),
    );
    var item2 =  InkWell(
      onTap: (){

        setState(() {

        });
        _controller.animateTo(2);
      },
      child: Padding(padding:  EdgeInsets.all(10)
        ,child: Container(

          padding: EdgeInsets.all(15.0),
          decoration: const BoxDecoration(

              color: Colors.green,
              borderRadius:  BorderRadius.all(
                  Radius.circular(10.0))
          ),
          child: Column(
            children:  [

              const Text("طلبات واصلة" , style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children:  [
                  Text((items.isNotEmpty)? "العدد : " + items[0]['done'].toString()  : "...." ,style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),),
                  Text((items.isNotEmpty)? "المبلغ الصافي : " + items[0]['price_done'].toString() + " د.ع "  : "...." , style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),),

                ],
              ),




            ],
          ),


        ),

      ),
    );
    var item3 =  InkWell(
      onTap: (){

        setState(() {
          _controller.animateTo(3);

        });

      },
      child: Padding(padding:  EdgeInsets.all(10)
        ,child: Container(
          padding: EdgeInsets.all(15.0),
          decoration: const BoxDecoration(

              color: Colors.red,
              borderRadius:  BorderRadius.all(
                  Radius.circular(10.0))
          ),
          child: Column(
            children:  [

              const Text("طلبات راجعة" , style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children:  [
                  Text((items.isNotEmpty)? "العدد : " + items[0]['done'].toString()  : "....",style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),),
                  Text((items.isNotEmpty)? "المبلغ الصافي : " + items[0]['price_back'].toString() + " د.ع "  : "....", style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),),

                ],
              ),




            ],
          ),

        ),


      ),
    );

    return  Directionality(textDirection: TextDirection.rtl,
        child: Scaffold(

          body: Container(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children:  [
                const SizedBox(height: 10,),
                const Center(child: Text("- الاحصائيات - "),),
                item1,
                item2,
                item3,
                const Divider(
                  indent: 10.0,
                  endIndent: 20.0,
                  thickness: 1,
                ),
                TextButton.icon(onPressed: null, icon: const Icon(Icons.person_pin , color: Colors.black,), label:   Text((items.isNotEmpty)? items[0]['username'] : "...", style: const TextStyle(
                    color: Colors.black
                ),)),


                 Text((items.isNotEmpty)? "مجموع المبلغ الكلي : " + items[0]['total_all'].toString() + " د.ع "  : "...." , style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
                const SizedBox(height: 10,),
                 Text((items.isNotEmpty)? "مجموع المبلغ المستلم : " + items[0]['total_ok'].toString() + " د.ع "  : "...."  , style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
                const SizedBox(height: 10,),
                 Text((items.isNotEmpty)? "مجموع المبلغ المستحق : " + items[0]['total_no'].toString() + " د.ع "  : "...."  , style: const TextStyle(
                  color: Colors.lightGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),






              ],
            ),
          ),

        )
    );
  }


}
