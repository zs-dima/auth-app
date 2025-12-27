// ignore_for_file: argument_type_not_assignable, avoid_web_libraries_in_flutter
import 'dart:convert';

import 'package:auth_app/update/model/version_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

abstract class UpdateCheckApi {
  Future<VersionModel> getNewVersion();
  Future<void> updateApplication();
  Future<void> tryReloadApplication();
}

class UpdateCheckApiImpl implements UpdateCheckApi {
  const UpdateCheckApiImpl();

  @override
  Future<VersionModel> getNewVersion() async {
    final uri = Uri.parse('${Uri.base.origin}/version.json?v=${DateTime.now().millisecondsSinceEpoch}');
    final response = await http.get(
      uri,
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );

    return VersionModel.fromJson(json.decode(response.body));
  }

  @override
  Future<void> updateApplication() async {
    final preferences = await SharedPreferences.getInstance();

    // Set flag to reload second time website after application updated
    await preferences.setBool('wait_update', true);

    web.window.location.reload();
  }

  @override
  Future<void> tryReloadApplication() async {
    final preferences = await SharedPreferences.getInstance();
    final waitUpdate = preferences.getBool('wait_update') ?? false;
    if (!waitUpdate) return;

    // Remove flag to prevent infinite reload
    await preferences.setBool('wait_update', false);

    // Try to reload website second time after application updated,
    // as first reload updates scripts only
    web.window.location.reload();
  }
}
