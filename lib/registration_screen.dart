import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:meeting_hall/user_sheet.dart';
import 'UserFields.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SheetsFlutter.init();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, home: RegistrationScreen()));
}

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _empnoController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  //fetch the data from google sheet and
  List<Map<String, String>> userData = [];

  Future<void> fetchGoogleSheetData() async {
    final response = await http.get(
      Uri.parse(
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vQMnH5gGr7L-M4XcMc97lkUtqCecfJM5wKCnvZ7joeOdjBTXqL01Z6Z7FtZm05e9X83wtLUlfZgOfAw/pub?output=csv'),
    );

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> csvList = CsvToListConverter().convert(csvData);
      for (var i = 1; i < csvList.length; i++) {
        userData.add({
          'EmployeeNumber': csvList[i][0].toString(),
          'Password': csvList[i][1].toString(),
          'Email':csvList[i][2].toString(),
        });
      }
    } else {
      // Handle HTTP error
      print('HTTP Error: ${response.statusCode}');
    }
  }

    @override
    void initState() {
      super.initState();
      fetchGoogleSheetData();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _empnoController,
                  decoration: InputDecoration(labelText: 'EmployeeNumber'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'EmployeeNumber is required';
                    }

                    // Use a regular expression to check if the value is an 8-digit number
                    if (value.length != 8 || int.tryParse(value) == null) {
                      return 'EmployeeNumber must be an 8-digit number';
                    }

                    return null; // Validation passed
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }

                    // Use a regular expression to validate the password
                    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%^&*()_+{}|:<>?])[A-Za-z\d!@#\$%^&*()_+{}|:<>?]+$');

                    if (!regex.hasMatch(value)) {
                      return 'Password must meet the following criteria:\n'
                          '- At least one special character\n'
                          '- At least one uppercase letter\n'
                          '- At least one lowercase letter\n'
                          '- At least one number';
                    }

                    return null; // Validation passed
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
// Use a regular expression to validate Gmail addresses without uppercase letters
                    final emailRegex = RegExp(r'^[a-z0-9._%+-]+@gmail\.com$');


                    if (!emailRegex.hasMatch(value)) {
                      return 'Invalid email address. Please use a Gmail address.';
                    }

                    return null; // Validation passed
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool isExistingUser = false;
                      for (var user in userData) {
                        if (user['EmployeeNumber'] == _empnoController.text &&
                            user['Password'] == _passwordController.text ||
                            user['Email']==_emailController.text) {
                          isExistingUser = true;
                          break;
                        }
                      }
                      if (isExistingUser) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'User with the same credentials already exists.'),
                          ),
                        );
                      } else {
                        final user = User(
                          empno: _empnoController.text,
                          password: _passwordController.text,
                          email: _emailController.text,
                        );
                        await SheetsFlutter.insert([user.toJson()]);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (BuildContext context) => LoginPage()),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Enter the employee number and password'),
                        ),
                      );
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

