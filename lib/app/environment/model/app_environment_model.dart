// ignore_for_file: invalid_annotation_target

import 'package:auth_app/app/environment/model/environment_variables.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_environment_model.freezed.dart';
part 'app_environment_model.g.dart';

@freezed
sealed class AppEnvironmentModel with _$AppEnvironmentModel {
  const factory AppEnvironmentModel({
    // --- APP --- //
    @JsonKey(name: EnvironmentVariables.appVersion) String? version,
    @JsonKey(name: EnvironmentVariables.environment) String? environment,
    @JsonKey(name: EnvironmentVariables.sentryDsn) String? sentryDsn,
    // --- DATABASE --- //
    @JsonKey(name: EnvironmentVariables.dropDatabase) bool? dropDatabase,
    @JsonKey(name: EnvironmentVariables.databaseName) String? databaseName,
    @JsonKey(name: EnvironmentVariables.inMemoryDatabase) bool? inMemoryDatabase,
    // --- API --- //
    @JsonKey(name: EnvironmentVariables.authAddress) String? authAddress,
    @JsonKey(name: EnvironmentVariables.apiAddress) String? apiAddress,
  }) = _AppEnvironmentModel;

  factory AppEnvironmentModel.fromJson(Map<String, dynamic> json) => _$AppEnvironmentModelFromJson(json);
}
