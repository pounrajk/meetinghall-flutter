class UserFields2{
  static String meetingName='MeetingHall';
  static String date='Date';
  static String startTime='StartTime';
  static String endTime='EndTime';

  static List getFields2() =>[meetingName,date,startTime,endTime];
}
class User2{
  final String meetingName;
  final String date;
  final String startTime;
  final String endTime;

  const User2({
    required this.meetingName,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
  Map<String,dynamic> toJson2()=>{
    UserFields2.meetingName: meetingName,
    UserFields2.date: date,
    UserFields2.startTime: startTime,
    UserFields2.endTime: endTime,
  };

  static User2 fromJson(Map<String, dynamic>? json)=> User2(
    meetingName: json?[UserFields2.meetingName],
    date: json?[UserFields2.date],
    startTime: json?[UserFields2.startTime],
    endTime: json?[UserFields2.endTime],

  );
}