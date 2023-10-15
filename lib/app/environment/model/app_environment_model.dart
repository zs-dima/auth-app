// ignore_for_file: invalid_annotation_target

import 'package:auth_app/app/environment/model/environment_variables.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_environment_model.freezed.dart';
part 'app_environment_model.g.dart';

@freezed
class AppEnvironmentModel with _$AppEnvironmentModel {
  const factory AppEnvironmentModel({
    @JsonKey(name: EnvironmentVariables.appVersion) String? version,
    @JsonKey(name: EnvironmentVariables.environment) String? environment,
    @JsonKey(name: EnvironmentVariables.authAddress) String? authAddress,
    @JsonKey(name: EnvironmentVariables.apiAddress) String? apiAddress,
    @JsonKey(name: EnvironmentVariables.sentryDsn) String? sentryDsn,
  }) = _AppEnvironmentModel;

  factory AppEnvironmentModel.fromJson(Map<String, dynamic> json) => _$AppEnvironmentModelFromJson(json);
}
