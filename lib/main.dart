import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:meeting_hall/registration_screen.dart';
import 'package:meeting_hall/user_sheet.dart';
import 'package:meeting_hall/user_sheet2.dart';

import 'MeetingHallScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SheetsFlutter.init();
  await SheetsFlutter2.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController empnoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<Map<String, String>> userData = [];

  Future<void> fetchGoogleSheetData() async {
    final response = await http.get(
      Uri.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vQMnH5gGr7L-M4XcMc97lkUtqCecfJM5wKCnvZ7joeOdjBTXqL01Z6Z7FtZm05e9X83wtLUlfZgOfAw/pub?output=csv'),
    );

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> csvList = CsvToListConverter().convert(csvData);
      for (var i = 1; i < csvList.length; i++) {
        userData.add({
          'EmployeeNumber': csvList[i][0].toString(),
          'Password': csvList[i][1].toString(),
        });
      }
    } else {
      // Handle HTTP error
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void login() {
    final enteredempno = empnoController.text;
    final enteredPassword = passwordController.text;

    // Check if entered username and password match any record in userData
    bool isCredentialsValid = false;
    for (var user in userData) {
      if (user['EmployeeNumber'] == enteredempno && user['Password'] == enteredPassword) {
        isCredentialsValid = true;
        break;
      }
    }

    if (isCredentialsValid) {
      // Navigate to the next screen (replace with your actual navigation logic)
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MeetingHallApp()));
    } else {
      // Show an error message (replace with your own error handling)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid username or password'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch Google Sheet data when the page loads
    fetchGoogleSheetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: empnoController,
              decoration: InputDecoration(
                labelText: 'EmployeeNumber',
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true, // Hide the password text
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),

            ElevatedButton(onPressed: (){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ( BuildContext context)=> RegistrationScreen()));
            },child: Text('Register')),

          ],
        ),
      ),
    );
  }
}
