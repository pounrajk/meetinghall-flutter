class UserFields{
  static String empno='EmployeeNumber';
  static String password='Password';
  static String email='Email';

  static List getFields() =>[empno,password,email];
}
class User{
  final String empno;
  final String password;
  final String email;

  const User({
    required this.empno,
    required this.password,
    required this.email
   });
  Map<String,dynamic> toJson()=>{
    UserFields.empno: empno,
    UserFields.password: password,
    UserFields.email: email,
  };

  static User fromJson(Map<String, dynamic>? json)=> User(
    empno: json?[UserFields.empno],
    password: json?[UserFields.password],
    email: json?[UserFields.email],
  );
}