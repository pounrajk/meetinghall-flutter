import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'MeetingHallScreen.dart';

void main() {
  runApp(MaterialApp(
    home: MeetingDetailsPage(),
  ));
}

class MeetingDetailsPage extends StatefulWidget {
  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  String selectedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  List<Map<String, String>>? meetingData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meeting Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('Select Date'),
              ),
              ElevatedButton(onPressed: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ( BuildContext context)=> MeetingHallApp()));
              },
                  child: Text('Back To Meeting Hall')),
              SizedBox(height: 16.0),
              Text(
                'Selected Date: $selectedDate',
                style: TextStyle(fontSize: 18.0),
              ),
              if (meetingData != null && meetingData!.isNotEmpty)
                for (final meeting in meetingData!)
                  ListTile(
                    title: Text('Meeting Hall Name: ${meeting['MeetingHall']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${meeting['Date']}'),
                        Text('StartTime: ${meeting['StartTime']}'),
                        Text('EndTime: ${meeting['EndTime']}'),
                      ],
                    ),
                  )
              else
                Text('No meetings found for the selected date.'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('dd-MM-yyyy').parse(selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );
    if (picked != null) {
      setState(() {
        // Format the selected date to match your requirements ('dd-MM-yyyy')
        selectedDate = DateFormat('dd-MM-yyyy').format(picked);
        fetchData();
      });
    }
  }

  Future<void> fetchData() async {
    final data = await fetchDataFromGoogleSheets(selectedDate);
    setState(() {
      meetingData = data;
      print('${data}');
    });
  }

  Future<List<Map<String, String>>?> fetchDataFromGoogleSheets(String date) async {
    final response = await http.get(
      Uri.parse(
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vQMnH5gGr7L-M4XcMc97lkUtqCecfJM5wKCnvZ7joeOdjBTXqL01Z6Z7FtZm05e9X83wtLUlfZgOfAw/pub?gid=1809233388&single=true&output=csv'),
    );

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> csvList = CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(csvData);

      final List<Map<String, String>> data = [];

      for (var i = 1; i < csvList.length; i++) {
        print('${csvData}');
        if (csvList[i][1].toString() == date) {
          data.add({
            'MeetingHall': csvList[i][0].toString(),
            'Date': csvList[i][1].toString(),
            'StartTime': csvList[i][2].toString(),
            'EndTime': csvList[i][3].toString(),
          });
        }
      }
      return data;
    } else {
      print('HTTP Error: ${response.statusCode}');
      return null;
    }
  }
}
