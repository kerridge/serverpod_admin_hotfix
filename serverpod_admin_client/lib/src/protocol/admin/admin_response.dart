/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:serverpod_admin_client/src/protocol/protocol.dart' as _i2;

abstract class AdminResponse implements _i1.SerializableModel {
  AdminResponse._({
    required this.authStrategy,
    required this.token,
    this.tokenExpiresAt,
    this.refreshToken,
    required this.authUserId,
    required this.scopeNames,
    required this.isSuperuser,
    required this.isStaff,
  });

  factory AdminResponse({
    required String authStrategy,
    required String token,
    DateTime? tokenExpiresAt,
    String? refreshToken,
    required String authUserId,
    required List<String> scopeNames,
    required bool isSuperuser,
    required bool isStaff,
  }) = _AdminResponseImpl;

  factory AdminResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminResponse(
      authStrategy: jsonSerialization['authStrategy'] as String,
      token: jsonSerialization['token'] as String,
      tokenExpiresAt: jsonSerialization['tokenExpiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['tokenExpiresAt'],
            ),
      refreshToken: jsonSerialization['refreshToken'] as String?,
      authUserId: jsonSerialization['authUserId'] as String,
      scopeNames: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['scopeNames'],
      ),
      isSuperuser: jsonSerialization['isSuperuser'] as bool,
      isStaff: jsonSerialization['isStaff'] as bool,
    );
  }

  String authStrategy;

  String token;

  DateTime? tokenExpiresAt;

  String? refreshToken;

  String authUserId;

  List<String> scopeNames;

  bool isSuperuser;

  bool isStaff;

  /// Returns a shallow copy of this [AdminResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminResponse copyWith({
    String? authStrategy,
    String? token,
    DateTime? tokenExpiresAt,
    String? refreshToken,
    String? authUserId,
    List<String>? scopeNames,
    bool? isSuperuser,
    bool? isStaff,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminResponse',
      'authStrategy': authStrategy,
      'token': token,
      if (tokenExpiresAt != null) 'tokenExpiresAt': tokenExpiresAt?.toJson(),
      if (refreshToken != null) 'refreshToken': refreshToken,
      'authUserId': authUserId,
      'scopeNames': scopeNames.toJson(),
      'isSuperuser': isSuperuser,
      'isStaff': isStaff,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminResponseImpl extends AdminResponse {
  _AdminResponseImpl({
    required String authStrategy,
    required String token,
    DateTime? tokenExpiresAt,
    String? refreshToken,
    required String authUserId,
    required List<String> scopeNames,
    required bool isSuperuser,
    required bool isStaff,
  }) : super._(
         authStrategy: authStrategy,
         token: token,
         tokenExpiresAt: tokenExpiresAt,
         refreshToken: refreshToken,
         authUserId: authUserId,
         scopeNames: scopeNames,
         isSuperuser: isSuperuser,
         isStaff: isStaff,
       );

  /// Returns a shallow copy of this [AdminResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminResponse copyWith({
    String? authStrategy,
    String? token,
    Object? tokenExpiresAt = _Undefined,
    Object? refreshToken = _Undefined,
    String? authUserId,
    List<String>? scopeNames,
    bool? isSuperuser,
    bool? isStaff,
  }) {
    return AdminResponse(
      authStrategy: authStrategy ?? this.authStrategy,
      token: token ?? this.token,
      tokenExpiresAt: tokenExpiresAt is DateTime?
          ? tokenExpiresAt
          : this.tokenExpiresAt,
      refreshToken: refreshToken is String? ? refreshToken : this.refreshToken,
      authUserId: authUserId ?? this.authUserId,
      scopeNames: scopeNames ?? this.scopeNames.map((e0) => e0).toList(),
      isSuperuser: isSuperuser ?? this.isSuperuser,
      isStaff: isStaff ?? this.isStaff,
    );
  }
}
