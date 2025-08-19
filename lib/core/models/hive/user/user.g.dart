// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      email: fields[5] as String?,
      token: fields[1] as String?,
      name: fields[3] as String?,
      organizationId: fields[6] as String?,
      organizationName: fields[4] as String?,
      id: fields[2] as String?,
      userType: UserType.values[fields[7] as int? ?? 0],
      organizationType: OrganizationType.values[fields[8] as int? ?? 0],
      userRole: UserRole.values[fields[9] as int? ?? 0],
      phone: fields[10] as String?,
      logoUrl: fields[12] as String?,
      fcmToken: fields[13] as String?,
      industry: fields[14] as String?,
      language: fields[15] as String?,
      address: fields[16] as Address?,
      yourName: fields[17] as String?,
      designation: fields[18] as String?,
      fullName: fields[19] as String?,
      isEmailVerified: fields[20] as bool?,
      isPhoneVerified: fields[21] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(20)
      ..writeByte(1)
      ..write(obj.token)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.organizationName)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.organizationId)
      ..writeByte(7)
      ..write(obj.userType?.index ?? 0)
      ..writeByte(8)
      ..write(obj.organizationType?.index ?? 0)
      ..writeByte(9)
      ..write(obj.userRole?.index ?? 0)
      ..writeByte(10)
      ..write(obj.phone)
      ..writeByte(12)
      ..write(obj.logoUrl)
      ..writeByte(13)
      ..write(obj.fcmToken)
      ..writeByte(14)
      ..write(obj.industry)
      ..writeByte(15)
      ..write(obj.language)
      ..writeByte(16)
      ..write(obj.address)
      ..writeByte(17)
      ..write(obj.yourName)
      ..writeByte(18)
      ..write(obj.designation)
      ..writeByte(19)
      ..write(obj.fullName)
      ..writeByte(20)
      ..write(obj.isEmailVerified)
      ..writeByte(21)
      ..write(obj.isPhoneVerified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 10;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      addressLine1: fields[1] as String?,
      addressLine2: fields[2] as String?,
      city: fields[3] as String?,
      state: fields[4] as String?,
      country: fields[5] as String?,
      pinCode: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.addressLine1)
      ..writeByte(2)
      ..write(obj.addressLine2)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.country)
      ..writeByte(6)
      ..write(obj.pinCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
