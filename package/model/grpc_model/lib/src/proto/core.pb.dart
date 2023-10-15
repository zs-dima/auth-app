//
//  Generated code. Do not modify.
//  source: core.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/timestamp.pb.dart' as $0;

class UUID extends $pb.GeneratedMessage {
  factory UUID({
    $core.String? value,
  }) {
    final $result = create();
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  UUID._() : super();
  factory UUID.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory UUID.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UUID',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'core'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  UUID clone() => UUID()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  UUID copyWith(void Function(UUID) updates) => super.copyWith((message) => updates(message as UUID)) as UUID;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UUID create() => UUID._();
  UUID createEmptyInstance() => create();
  static $pb.PbList<UUID> createRepeated() => $pb.PbList<UUID>();
  @$core.pragma('dart2js:noInline')
  static UUID getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UUID>(create);
  static UUID? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => clearField(1);
}

class ResultReply extends $pb.GeneratedMessage {
  factory ResultReply({
    $core.bool? result,
  }) {
    final $result = create();
    if (result != null) {
      $result.result = result;
    }
    return $result;
  }
  ResultReply._() : super();
  factory ResultReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ResultReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResultReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'core'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'result')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ResultReply clone() => ResultReply()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ResultReply copyWith(void Function(ResultReply) updates) =>
      super.copyWith((message) => updates(message as ResultReply)) as ResultReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResultReply create() => ResultReply._();
  ResultReply createEmptyInstance() => create();
  static $pb.PbList<ResultReply> createRepeated() => $pb.PbList<ResultReply>();
  @$core.pragma('dart2js:noInline')
  static ResultReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResultReply>(create);
  static ResultReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get result => $_getBF(0);
  @$pb.TagNumber(1)
  set result($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => clearField(1);
}

/// Name "DecimalValue" prevents conflict with C# Decimal type
/// Adapted from https://github.com/googleapis/googleapis/blob/master/google/type/money.proto
class DecimalValue extends $pb.GeneratedMessage {
  factory DecimalValue({
    $fixnum.Int64? units,
    $core.int? nanos,
  }) {
    final $result = create();
    if (units != null) {
      $result.units = units;
    }
    if (nanos != null) {
      $result.nanos = nanos;
    }
    return $result;
  }
  DecimalValue._() : super();
  factory DecimalValue.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DecimalValue.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecimalValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'core'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'units')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'nanos', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DecimalValue clone() => DecimalValue()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DecimalValue copyWith(void Function(DecimalValue) updates) =>
      super.copyWith((message) => updates(message as DecimalValue)) as DecimalValue;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecimalValue create() => DecimalValue._();
  DecimalValue createEmptyInstance() => create();
  static $pb.PbList<DecimalValue> createRepeated() => $pb.PbList<DecimalValue>();
  @$core.pragma('dart2js:noInline')
  static DecimalValue getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecimalValue>(create);
  static DecimalValue? _defaultInstance;

  /// The whole units of the amount.
  @$pb.TagNumber(1)
  $fixnum.Int64 get units => $_getI64(0);
  @$pb.TagNumber(1)
  set units($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUnits() => $_has(0);
  @$pb.TagNumber(1)
  void clearUnits() => clearField(1);

  /// Number of nano (10^-9) units of the amount.
  /// The value must be between -999,999,999 and +999,999,999 inclusive.
  /// If `units` is positive, `nanos` must be positive or zero.
  /// If `units` is zero, `nanos` can be positive, zero, or negative.
  /// If `units` is negative, `nanos` must be negative or zero.
  /// For example $-1.75 is represented as `units`=-1 and `nanos`=-750,000,000.
  @$pb.TagNumber(2)
  $core.int get nanos => $_getIZ(1);
  @$pb.TagNumber(2)
  set nanos($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasNanos() => $_has(1);
  @$pb.TagNumber(2)
  void clearNanos() => clearField(2);
}

class DateRange extends $pb.GeneratedMessage {
  factory DateRange({
    $0.Timestamp? fromDate,
    $0.Timestamp? toDate,
  }) {
    final $result = create();
    if (fromDate != null) {
      $result.fromDate = fromDate;
    }
    if (toDate != null) {
      $result.toDate = toDate;
    }
    return $result;
  }
  DateRange._() : super();
  factory DateRange.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DateRange.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DateRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'core'), createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'fromDate', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'toDate', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DateRange clone() => DateRange()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DateRange copyWith(void Function(DateRange) updates) =>
      super.copyWith((message) => updates(message as DateRange)) as DateRange;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DateRange create() => DateRange._();
  DateRange createEmptyInstance() => create();
  static $pb.PbList<DateRange> createRepeated() => $pb.PbList<DateRange>();
  @$core.pragma('dart2js:noInline')
  static DateRange getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DateRange>(create);
  static DateRange? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get fromDate => $_getN(0);
  @$pb.TagNumber(1)
  set fromDate($0.Timestamp v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFromDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromDate() => clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureFromDate() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Timestamp get toDate => $_getN(1);
  @$pb.TagNumber(2)
  set toDate($0.Timestamp v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasToDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearToDate() => clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureToDate() => $_ensure(1);
}

class FileBytes extends $pb.GeneratedMessage {
  factory FileBytes({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FileBytes._() : super();
  factory FileBytes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FileBytes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileBytes',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'core'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FileBytes clone() => FileBytes()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FileBytes copyWith(void Function(FileBytes) updates) =>
      super.copyWith((message) => updates(message as FileBytes)) as FileBytes;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileBytes create() => FileBytes._();
  FileBytes createEmptyInstance() => create();
  static $pb.PbList<FileBytes> createRepeated() => $pb.PbList<FileBytes>();
  @$core.pragma('dart2js:noInline')
  static FileBytes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileBytes>(create);
  static FileBytes? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class FileData extends $pb.GeneratedMessage {
  factory FileData({
    $core.String? fileName,
    $core.String? fileHash,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (fileName != null) {
      $result.fileName = fileName;
    }
    if (fileHash != null) {
      $result.fileHash = fileHash;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FileData._() : super();
  factory FileData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FileData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'core'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fileName')
    ..aOS(2, _omitFieldNames ? '' : 'fileHash')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FileData clone() => FileData()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FileData copyWith(void Function(FileData) updates) =>
      super.copyWith((message) => updates(message as FileData)) as FileData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileData create() => FileData._();
  FileData createEmptyInstance() => create();
  static $pb.PbList<FileData> createRepeated() => $pb.PbList<FileData>();
  @$core.pragma('dart2js:noInline')
  static FileData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileData>(create);
  static FileData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileHash($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasFileHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
