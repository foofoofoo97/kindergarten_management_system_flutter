import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DataBaseService {
  // singleton boilerplate
  static final DataBaseService _cameraServiceService = DataBaseService._internal();

  factory DataBaseService() {
    return _cameraServiceService;
  }
  // singleton boilerplate
  DataBaseService._internal();

  /// file that stores the data on filesystem
  File jsonFile;

  /// Data learned on memory
  Map<String, dynamic> _db = Map<String, dynamic>();
  Map<String, dynamic> get db => this._db;

  /// loads a simple json file.
  Future loadDB() async {
    try {
      var tempDir = await getApplicationDocumentsDirectory();
      String _embPath = tempDir.path + '/emb.json';

      jsonFile = new File(_embPath);
      final url = 'https://firebasestorage.googleapis.com/v0/b/kiki-fyp.appspot.com/o/face_recognition.json?alt=media&token=2aa5a228-34c1-419f-9a7f-090007e69dbf';
      final response = await http.get(url);

      if (response.statusCode == 200) {
          _db = json.decode(response.body);
          print('yes');
          print(_db);
      }
      else{
        print('no');
        _db.clear();
      }

    }catch(e){
      print('error');
      print(e);
    }
  }

  /// [Name]: name of the new user
  /// [Data]: Face representation for Machine Learning model
  Future saveData(String user, String password, List modelData) async {
    String userAndPass = user + ':' + password;
    _db[userAndPass] = modelData;
    jsonFile.writeAsStringSync(json.encode(_db));
   await uploadImageToFirebase(jsonFile);
  }


  /// deletes the created users
  cleanDB() async{
    this._db = Map<String, dynamic>();
    jsonFile.writeAsStringSync(json.encode({}));
    StorageReference fileRef = await FirebaseStorage.instance.getReferenceFromUrl('https://firebasestorage.googleapis.com/v0/b/kiki-fyp.appspot.com/o/face_recognition.json?alt=media&token=2aa5a228-34c1-419f-9a7f-090007e69dbf');
    await fileRef.delete();
  }


  Future<dynamic> uploadImageToFirebase(File file) async {
    StorageReference storageReference =
    FirebaseStorage.instance.ref().child("/face_recognition.json");
    StorageUploadTask uploadTask = storageReference.putFile(file);
    StorageTaskSnapshot _snapshot = await uploadTask.onComplete;

    print(await _snapshot.ref.getDownloadURL());
  }
}
