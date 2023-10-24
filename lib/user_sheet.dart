import 'package:gsheets/gsheets.dart';

import 'UserFields.dart';


class SheetsFlutter{
  static final String _sheetID= "1ucwn42l3-WJNl5RlYFP_qORfx_MMuB2YBbsohwC3KHo";
  static const _sheetCredential=r'''
  {
  "type": "service_account", 
  "project_id": "solar-vertex-401705",
  "private_key_id": "da253a21c8e0fcef7acb07121e2587e57e7513ba",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCtL1h7GK5e8HVp\nXplMKRV0NmvPVFDmJ4ahHItzMcOTreQik22wKHR7AqFN727d6lSEhApPf9FWxcPZ\nRxfK1mKIWWzTyPBD+EuJPM7iI/LAzf9YuIYwgQg5ScvTI86+dtysiWLC1k7W1Rb4\nPOdA/W2rtNrg6wMkotx5t8B3znOYu0hO8+SxeqHihas9qnLFscZren8KBZz8zRSD\nllZEksIyS1MTKNCTDa++R3ZbaMkDOjDyOKRYpTItzoc24PlIn5pCiwsPn7SA/5Rd\nwtTds5rIFnZhIvHMDYCEF+cyaUbP/zKhoqGMMjkvb33sma6205N2KhflDeizhwp+\nnRMM0IdhAgMBAAECggEAEbZPPP0KjbiCCZjHN5GBbt/x/sOyJ8J7Hmx7m/hxoYpI\nqXtH3fBamV9s0o+zrbaS65/6006l66imSHPg7GR+B1E+CXBPl7lZNbFREgfN2AeO\nygAf7piubU2C2cFGb8GwUrpqWLWaXUEbQaAuS+ifbXmTDoB6qHs6Q/3rDVXBX36n\nlTzIO5opbNWv5ObaCZpbXBTgYy9zNQTQadxha8S/v19x7yK22tCb+hGi72NWfFlN\n71mdAtnlkVk167BiFPROZ3dIcAVFl1PjP6N3CGy68T/dSlgfrrFUQB47XHuLsJcO\nKSzn+e5Y1C7syj09NYbEFVaGnHedWXWtTaDriyXWUQKBgQDVElCxpAR6MNkFYEgK\n//Rfo7abOY6m2gudMqoj1+IqHIy0nF4AMqwsqFT+w6oZMslwWwMOiHqRRoBm3Xjx\np8AGadGzns64S27XRL2TN8CIi74AehzYtH4hxr1VWLOJONApiQdWzQVx9n6y84dc\nQnzDFIUVilg02OXNb8yYafo10wKBgQDQE8gdZRAc768diqDUOa5XgvTcoau68WiZ\nIUcGEC2VIGs0cQNQzUdvBVW7idt9XAitHMB+rOrNsgiKMB67ZL3WuEVwn85GiW7t\ni6ajOYoJgLuDuHmr2igicKrzA3WRiQYJpcFkDMw4iSgpfwdX5k9rV51SS0vcp6Pi\nB828OZLJewKBgDMIlP1HTK87ne9UtUy1K4Hww18AdTNvjFKVfPziy0/M0MK9pSIl\nAOodU2ZF1Sr96BOaKOxFMh4zpbN9nmc7B5pBpDGCev7XSnATDdkCBIJv/g09MkWR\nTZinclfLzAy0597a7EAVERXPtV8FR0mIvzs2Yf3bye62eKww9+8VixFzAoGBAM6R\ntOspt9NiR/EF/SBzmxcZ1Ulr3vcaToMnPEFSsk4H/yXyxB3ljXM0UqZ598L+KUbi\n8l9P/1Lx2fSGTRwwqR6PlbB3lesE6XE+YNJOfzFr8byU2YW4cHuwaqYS2xb+d1YA\njntrERtXXt3DVGD5LgMc2fwm8EtAyjvND3w7k/QdAoGAXhRc2WQajzNY35/Gvdt9\nEUMAh6hx0mNKI9lRYwti3tFhsokYR5Wjm3n4AypDoSjVFHlhkpbSCRyh7edAFS5w\nHzZ8y42mL+abNrDSt7PcvyGSoQLbwM0TiJWn9R2sPfG3e3ZUwslzkPUyLqnmUxpS\nzrh3SV9a3IsQk7jeBp7nx1Y=\n-----END PRIVATE KEY-----\n",
  "client_email": "meetingsheet@solar-vertex-401705.iam.gserviceaccount.com",
  "client_id": "109775398561032808434",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/meetingsheet%40solar-vertex-401705.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';

  static Worksheet? _usersheet;
  static final _gsheets=GSheets(_sheetCredential);

  static Future init() async {
   try{
     final  spreadsheet= await _gsheets.spreadsheet(_sheetID);
     _usersheet =await _getWorkSheet(spreadsheet, title: "meeting");
     final firstRow=UserFields.getFields();
     _usersheet!.values.insertRow(1, firstRow);

   }catch(e){
     print(e);
   }
  }
  static Future<Worksheet> _getWorkSheet(
      Spreadsheet spreadsheet, {
        required String title,
  }
      ) async{
    try{
      return await spreadsheet.addWorksheet(title);
    }catch(e){
      return spreadsheet.worksheetByTitle(title)!;
    }
  }
  static Future<User?> getByUser(String empno) async{
    if(_usersheet==null) return null;

    final json= await  _usersheet!.values.map.rowByKey(empno,fromColumn: 1);
    return json == null ? null:User.fromJson(json);
  }
  static Future insert(List<Map<String,dynamic>> rowList) async{
    if(_usersheet==null) return;
    _usersheet!.values.map.appendRows(rowList);
  }
}