import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'data.dart';

class ProfilesStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/profiles');
  }

  Future<bool> get isFileExists async {
    final file = await _localFile;
    return file.exists();
  }

  void createFile() async {
    final file = await _localFile;
    file.create();
  }

  void writeProfiles(List<Profile> list) async {
    final file = await _localFile;
    final jsonString = jsonEncode(list);
    file.writeAsString(jsonString);
  }

  Future<List<Profile>> readProfiles() async {
    try {
      final file = await _localFile;
      if (!file.existsSync())  return [];
      final contents = await file.readAsString();
      final listOfMaps = jsonDecode(contents);
      final List<Profile> listOfProfiles = listOfMaps.map<Profile>((e) => Profile.fromJson(e)).toList();
      return listOfProfiles;
    } catch (e) {
      return [];
    }
  }
}