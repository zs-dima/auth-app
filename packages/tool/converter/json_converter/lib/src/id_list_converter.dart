import 'dart:typed_data' as td;

import 'package:json_annotation/json_annotation.dart';

class IdListConverter implements JsonConverter<IdList, List<int>> {
  const IdListConverter();

  @override
  IdList fromJson(List<int> json) => .new(json);

  @override
  List<int> toJson(IdList object) => object.toList();

  // @override
  // IdList fromJson(Object? value) => //
  //     switch (value) {
  //   final String text => IdList.tryParse(text) ?? 0.0,
  //   final List v => v.toDouble(),
  //   _ => 0,
  // };

  // @override
  // Object toJson(IdList value) => value.toString();
}

typedef Id = int;

extension type const IdList(List<Id> _ids) implements Iterable<Id> {
  IdList addFirst(Id id) => .new(
    td.Uint32List(_ids.length + 1)
      ..first = id
      ..setAll(1, _ids),
  );

  IdList addLast(Id id) => .new(
    td.Uint32List(_ids.length + 1)
      ..setAll(0, _ids)
      ..last = id,
  );

  IdList add(Id id) => addLast(id);

  IdList remove(Id id) => .new(td.Uint32List.fromList(_ids)..remove(id));

  Id operator [](int index) => _ids[index];
}
