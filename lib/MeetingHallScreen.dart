import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'package:meeting_hall/UserFields2.dart';
import 'package:meeting_hall/user_sheet2.dart';
import 'package:http/http.dart' as http;

import 'meeting_details.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SheetsFlutter2.init();
  await SheetsFlutter2.init();
  runApp(MeetingHallApp());
}

class MeetingHallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MeetingHallScreen(),
      theme: ThemeData(brightness: Brightness.light),
    );
  }
}

class MeetingHallScreen extends StatefulWidget {
  @override
  _MeetingHallScreenState createState() => _MeetingHallScreenState();
}

class _MeetingHallScreenState extends State<MeetingHallScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  _MeetingHallScreenState(){
    selectedMeetingHall= availableMeetingHalls[0];
  }

  String selectedMeetingHall = '';
  List<String> availableMeetingHalls = ['Meeting Hall A', 'Meeting Hall B', 'Meeting Hall C', 'Meeting Hall D'];

  //datetime
  DateTime _selectedDate=DateTime.now();
  Future<void> openDatePicker() async{
    final selectedDate =await showDatePicker(context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000));
    if (selectedDate!=null){
      setState(() {
        _selectedDate=selectedDate;
      });
    }
  }
  String get getDate{
    return DateFormat('dd-MM-yyyy').format(_selectedDate);
  }

  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  String formatTimeOfDay(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> selectStartTime() async {
    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );

    if (pickedStartTime != null) {
      setState(() {
        selectedStartTime = pickedStartTime;
      });
    }
  }
  Future<void> selectEndTime() async {
    final pickedEndTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );

    if (pickedEndTime != null) {
      setState(() {
        selectedEndTime = pickedEndTime;
      });
    }
  }

  //fetch the data from google sheet and
  List<Map<String, String>> userData2 = [];

  // Future<void> fetchGoogleSheetData() async {
  //   final response = await http.get(
  //     Uri.parse(
  //         'https://docs.google.com/spreadsheets/d/e/2PACX-1vQMnH5gGr7L-M4XcMc97lkUtqCecfJM5wKCnvZ7joeOdjBTXqL01Z6Z7FtZm05e9X83wtLUlfZgOfAw/pub?output=csv'),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final csvData = response.body;
  //     final List<List<dynamic>> csvList = CsvToListConverter().convert(csvData);
  //     for (var i = 1; i < csvList.length; i++) {
  //       userData2.add({
  //         'MeetingHall': csvList[i][0].toString(),
  //         'Date': csvList[i][1].toString(),
  //         'StartTime':csvList[i][2].toString(),
  //         'EndTime':csvList[i][3].toString(),
  //       });
  //     }
  //   } else {
  //     // Handle HTTP error
  //     print('HTTP Error: ${response.statusCode}');
  //   }
  // }

  Future<void> fetchSecondSheetData() async {
    print('6');
    final response = await http.get(
      Uri.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vQMnH5gGr7L-M4XcMc97lkUtqCecfJM5wKCnvZ7joeOdjBTXqL01Z6Z7FtZm05e9X83wtLUlfZgOfAw/pub?gid=1809233388&single=true&output=csv'),
    );
    // Replace 'Sheet2' with the name of your second sheet.
    if (response.statusCode == 200) {
      print('5');
      final csvData = response.body;
      final List<List<dynamic>> csvList = CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(csvData);
      for (var i = 1; i < csvList.length; i++) {
        print('${csvData}');
        print('4');
        userData2.add({
          'MeetingHall': csvList[i][0].toString(),
          'Date': csvList[i][1].toString(),
          'StartTime':csvList[i][2].toString(),
          'EndTime':csvList[i][3].toString(),
        });
      }
    } else {
      // Handle HTTP error
      print('HTTP Error: ${response.statusCode}');
    }

  }
  bool isAlreadyBooked(String meetingHall, String date, String startTime, String endTime) {
    for (var booking in userData2) {
      if (booking['MeetingHall'] == meetingHall &&
          booking['Date'] == date &&
          (startTime.compareTo(booking['EndTime']!) < 0 || endTime.compareTo(booking['StartTime']!) > 0)) {
        return true; // The meeting hall is already booked for the selected time
      }
    }
    return false; // Not booked
  }

  @override
  void initState() {
    super.initState();
    fetchSecondSheetData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meeting Hall Booking'),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField(
                value: selectedMeetingHall,
                  items: availableMeetingHalls.map(
                  (e)=>DropdownMenuItem(child: Text(e), value: e,)
              ).toList(),
                  onChanged: (val){
                  setState(() {
                    selectedMeetingHall =val as String;
                  });
                  },
                icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                  ),
              SizedBox(height: 20),

              Row(
                children: [
                  ElevatedButton(onPressed: openDatePicker,
                    child: Text("Select Date"),

                  ),
                  SizedBox(height: 100),
                  Text('$getDate'),
                ],
              ),
              Column(
                children: [
                 Row(
                   children: [
                     ElevatedButton(
                       onPressed: selectStartTime,
                       child: Text('Select Start Time'),
                     ),
                     SizedBox(height: 10),
                     Text(
                       'Start Time: ${selectedStartTime.format(context)}',
                       style: TextStyle(fontSize: 16),
                     ),
                   ],
                 ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: selectEndTime,
                        child: Text('Select End Time'),
                      ),
                      Text(
                        'End Time: ${selectedEndTime.format(context)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 35),
              ElevatedButton(
                onPressed: () async {
                  print('5');
                  final selectedDate = getDate;
                  final selectedStart = formatTimeOfDay(selectedStartTime);
                  final selectedEnd = formatTimeOfDay(selectedEndTime);

                  if (selectedMeetingHall.isNotEmpty) {
                    if (isAlreadyBooked(selectedMeetingHall, selectedDate, selectedStart, selectedEnd)) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Meeting hall $selectedMeetingHall is already booked for the selected time.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Add the booking to the list and store it in Google Sheets
                      final user2 = User2(
                        meetingName: selectedMeetingHall.toString(),
                        date: getDate.toString(),
                        startTime: formatTimeOfDay(selectedStartTime),
                        endTime: formatTimeOfDay(selectedEndTime),
                      );

                      await SheetsFlutter2.insert([user2.toJson2()]); // Store in Google Sheets

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Booking Confirmation'),
                            content: Text('You have booked $selectedMeetingHall.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Please select a meeting hall.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        });
                  }
                },
                child: Text('Submit'),
              ),
              ElevatedButton(onPressed: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ( BuildContext context)=> MeetingDetailsPage()));
              },
                  child: Text('View Meeting'))
            ],
          ),
        ),
      ),
    );
  }
}
