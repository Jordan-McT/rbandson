import 'package:collection/collection.dart';

enum DeliveryState {
  INCOMING,
  STORAGE,
  LOADING,
  ASSIGNED,
  OUTGOING,
}

enum Province {
  WESTERN_CAPE,
  NORTHERN_CAPE,
  EASTERN_CAPE,
  FREE_STATE,
  NORTH_WEST,
  KWAZULU_NATAL,
  MPUMALANGA,
  GAUTENG,
  LIMPOPO,
}

enum Measurement {
  KG,
  T,
  ml,
  L,
}

enum Role {
  ADMIN,
  DRIVER,
  OFFICE,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (DeliveryState):
      return DeliveryState.values.deserialize(value) as T?;
    case (Province):
      return Province.values.deserialize(value) as T?;
    case (Measurement):
      return Measurement.values.deserialize(value) as T?;
    case (Role):
      return Role.values.deserialize(value) as T?;
    default:
      return null;
  }
}
