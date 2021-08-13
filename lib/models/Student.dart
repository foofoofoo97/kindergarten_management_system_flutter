class Student{
   var _firstName;
   var _lastName;
   var _age;
   var _kindergarten;
   var _uid;
   var _guardian;
   var _contact;
   var _performance;

   set performance(Map value)=>_performance=value;
   get performance=>_performance;

   set guardian(String value)=>_guardian=value;
   get guardian=>_guardian;

   set contact(String value)=>_contact=value;
   get contact=>_contact;

  set uid(String value)=>_uid=value;
  get uid=>_uid;

  set firstName(String value)=>_firstName=value;
  get firstName=>_firstName;

  set lastName(String value)=>_lastName=value;
  get lastName=>_lastName;

  set age(int value)=>_age=value;
  get age=>_age;

  set kindergarten(String value)=>_kindergarten=value;
  get kindergarten=>_kindergarten;
}