import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  String boxName = 'users';

  Future<Box> openBox() async {
    Box box = await Hive.openBox(boxName);
    return box;
  }

  // List getUser(Box box) {
  //   return box.values.toList().cast();
  // }

  // Future<void> addUsers(Box box, user) async {
  //   await box.put(movie.id, movie);
  // }

  // Future<void> updateMovie(Box box, Movie movie) async {
  //   await box.put(movie.id, movie);
  // }

  // Future<void> deleteMovie(Box box, Movie movie) async {
  //   await box.delete(movie.id);
  // }

  // Future<void> deleteAllMovie(Box box) async {
  //   await box.clear();
  // }
}
