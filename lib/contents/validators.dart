class Validators{
  static bool compulsoryValidator(String string){
    return string.length>0;
  }
  static bool emailValidator(String email){
   return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
  static bool passwordValidator(String password){
    return password.length>=6;
  }
  static bool numberValidator(String value){
    try{
       double number =  double.parse(value);
       return number>0;
    }
    catch(e){
      return false;
    }
  }

  static bool numberNotCompulsoryValidator(String value){
    try{
      if(value==null||value==''){
        return true;
      }
      double number =  double.parse(value);
      return number>0;
    }
    catch(e){
      return false;
    }
  }
}