import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/frontend/utils/constants.dart';

import 'package:flutter/cupertino.dart';

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

  Future<void> createimportantUserDB() async {
    try {
      final Database? db = _database;
      const keyType = "TEXT PRIMARY KEY";
      const descriptionType = "TEXT";

      await db!.execute(''' 
    CREATE TABLE ${Constants.userPrimaryDetailsSQLDatabse} (
     ${UserPrimaryFields.username} $keyType,
     ${UserPrimaryFields.email} $descriptionType,
     ${UserPrimaryFields.token} $descriptionType,
     ${UserPrimaryFields.profileImagePath} $descriptionType,
     ${UserPrimaryFields.profileImageURL} $descriptionType
     ${UserPrimaryFields.bio} $descriptionType
     ${UserPrimaryFields.notifications} $descriptionType
     ${UserPrimaryFields.accountCreationDate} $descriptionType
     ${UserPrimaryFields.accountCreationTime} $descriptionType
     ${UserPrimaryFields.mobileNumber} $descriptionType
     ${UserPrimaryFields.wallpaper} $descriptionType
     
      )
    ''');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> insertOrImportantUserDB(UserPrimaryModel model,
      {insert = true}) async {
    try {
      final Database? db = _database;

      if (insert) {
        await db!
            .insert(Constants.userPrimaryDetailsSQLDatabse, model.toJson());
      } else {
        await db!.update(
          Constants.userPrimaryDetailsSQLDatabse,
          model.toJson(),
          where: '${UserPrimaryFields.username} = ?',
          whereArgs: [model.userName],
        );
      }
    } catch (e) {
      e.toString();
      rethrow;
    }
  }

  // user_primary_detail_databse
}
