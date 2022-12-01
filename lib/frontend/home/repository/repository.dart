import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/models/user_secondary_details.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/frontend/utils/constants.dart';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HomeRepository {
  HomeRepository();
  static final HomeRepository instance = HomeRepository._init();

  static Database? _database;
  HomeRepository._init();

  Future<Database> get database async {
    try {
      if (_database != null) return _database!;

      _database = await _initDB('chatify.db');
      return _database!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Database> _initDB(String filepath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filepath);

      return await openDatabase(
        path,
        version: 1,
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<bool> createimportantUserDB() async {
    try {
      final Database db = await database;
      const keyType = "TEXT PRIMARY KEY";
      const descriptionType = "TEXT";

      // await db.execute(
      //     '''DROP TABLE IF EXISTS ${Constants.userPrimaryDetailsSQLDatabse}''');

      await db.execute(''' 
    CREATE TABLE IF NOT EXISTS ${Constants.userPrimaryDetailsSQLDatabse} (
     ${UserPrimaryFields.username} $keyType,
     ${UserPrimaryFields.email} $descriptionType,
     ${UserPrimaryFields.token} $descriptionType,
     ${UserPrimaryFields.profileImagePath} $descriptionType,
     ${UserPrimaryFields.profileImageURL} $descriptionType,
     ${UserPrimaryFields.bio} $descriptionType,
     ${UserPrimaryFields.notifications} $descriptionType,
     ${UserPrimaryFields.accountCreationDate} $descriptionType,
     ${UserPrimaryFields.accountCreationTime} $descriptionType,
     ${UserPrimaryFields.mobileNumber} $descriptionType,
     ${UserPrimaryFields.wallpaper} $descriptionType
     
      )

    ''');

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> insertOrUpdateImportantUserDB(UserPrimaryModel model,
      {insert = true}) async {
    UserRepository repo = UserRepository();
    final userData = await repo.getFirebaseToken(model.email);
    final token = userData['token'];
    final String currentDate = userData['creation_date'];
    final String currentTime = userData['creation_time'];
    try {
      model.accountCreationDate = currentDate;
      model.accountCreationTime = currentTime;
      model.token = token.toString();
      final Database? db = _database;

      int result;

      if (insert) {
        List<Map> count = await db!.query(
            Constants.userPrimaryDetailsSQLDatabse,
            where: "${UserPrimaryFields.username} = ?",
            whereArgs: [model.userName]);

        if (count.isEmpty) {
          result = await db.insert(
              Constants.userPrimaryDetailsSQLDatabse, model.toJson());
        } else {
          result = await db.update(
            Constants.userPrimaryDetailsSQLDatabse,
            model.toJson(),
            where: '${UserPrimaryFields.username} = ?',
            whereArgs: [model.userName],
          );
        }

        return true;
      } else {
        result = await db!.update(
          Constants.userPrimaryDetailsSQLDatabse,
          model.toJson(),
          where: '${UserPrimaryFields.username} = ?',
          whereArgs: [model.userName],
        );
        return result > 0 ? true : false;
      }
    } catch (e) {
      e.toString();
      return false;
    }
  }

  Future<bool> createSecondarytUserDB({required username}) async {
    try {
      final Database db = await database;
      const keyType = "TEXT PRIMARY KEY";
      const descriptionType = "TEXT";

      await db.execute(''' 
    CREATE TABLE IF NOT EXISTS ${username}_activities  (
     ${UserSecondaryFields.activityPath} $descriptionType,
     ${UserSecondaryFields.activityTime} $keyType,
     ${UserSecondaryFields.backgroundInformation} $descriptionType,
     ${UserSecondaryFields.extraTime} $descriptionType,
     ${UserSecondaryFields.specialOptions} $descriptionType,
     ${UserSecondaryFields.mediaType} $descriptionType
      )
    ''');

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> insertOrUpdateSecondaryUserDB(
    UserSecondaryModel model,
  ) async {
    try {
      final Database? db = _database;

      final int result = await db!
          .insert(Constants.userPrimaryDetailsSQLDatabse, model.toJson());

      return result > 0 ? true : false;
    } catch (e) {
      e.toString();
      return false;
    }
  }

  // user_primary_detail_databse
}
