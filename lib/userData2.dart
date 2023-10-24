import 'dart:convert';
import 'package:http/http.dart' as http;

const String sheetId = '1ucwn42l3-WJNl5RlYFP_qORfx_MMuB2YBbsohwC3KHo';
const String apiKey = 'da253a21c8e0fcef7acb07121e2587e57e7513ba';

Future<void> createData(Map<String, dynamic> data) async {
  final Uri uri = Uri.parse(
    'https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/Sheet2?key=$apiKey',
  );

  final response = await http.post(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'values': [data.values.toList()],
    }),
  );

  if (response.statusCode == 200) {
    print('Data added successfully');
  } else {
    throw Exception('Failed to add data');
  }
}

Future<List<List<dynamic>>> readData() async {
  final Uri uri = Uri.parse(
    'https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/Sheet2?key=$apiKey',
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<List<dynamic>> values = data['values'];
    return values;
  } else {
    throw Exception('Failed to fetch data');
  }
}

Future<void> updateData(Map<String, dynamic> newData, int row) async {
  final Uri uri = Uri.parse(
    'https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/Sheet2?key=$apiKey',
  );

  final response = await http.put(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'values': [newData.values.toList()],
    }),
  );

  if (response.statusCode == 200) {
    print('Data updated successfully');
  } else {
    throw Exception('Failed to update data');
  }
}

Future<void> deleteData(int row) async {
  final Uri uri = Uri.parse(
    'https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/Sheet2?key=$apiKey',
  );

  final response = await http.delete(uri);

  if (response.statusCode == 200) {
    print('Data deleted successfully');
  } else {
    throw Exception('Failed to delete data');
  }
}
