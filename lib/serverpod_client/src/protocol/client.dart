/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'protocol.dart' as _i4;

/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  /// 用戶登入
  _i2.Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'login',
        {
          'username': username,
          'password': password,
        },
      );

  /// 獲取用戶信息
  _i2.Future<Map<String, dynamic>> getUserInfo({required String username}) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'getUserInfo',
        {'username': username},
      );

  /// 獲取所有用戶列表
  _i2.Future<Map<String, dynamic>> getAllUsers() =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'getAllUsers',
        {},
      );

  /// 獲取所有住戶列表
  _i2.Future<Map<String, dynamic>> getAllResidents() =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'getAllResidents',
        {},
      );

  /// 新增住戶
  _i2.Future<Map<String, dynamic>> addResident({
    required String username,
    required String password,
    required String name,
    required String unit,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'addResident',
        {
          'username': username,
          'password': password,
          'name': name,
          'unit': unit,
        },
      );

  /// 刪除住戶
  _i2.Future<Map<String, dynamic>> deleteResident({required String username}) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'deleteResident',
        {'username': username},
      );

  /// 修改住戶信息
  _i2.Future<Map<String, dynamic>> updateResidentInfo({
    required String username,
    required String name,
    required String unit,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'updateResidentInfo',
        {
          'username': username,
          'name': name,
          'unit': unit,
        },
      );

  /// 生成邀請碼
  _i2.Future<Map<String, dynamic>> generateInvitationCode({
    required String createdBy,
    int? validDays,
    String? unit,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'generateInvitationCode',
        {
          'createdBy': createdBy,
          'validDays': validDays,
          'unit': unit,
        },
      );

  /// 獲取所有邀請碼列表
  _i2.Future<Map<String, dynamic>> getAllInvitationCodes() =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'getAllInvitationCodes',
        {},
      );

  /// 刪除邀請碼
  _i2.Future<Map<String, dynamic>> deleteInvitationCode(
          {required String code}) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'deleteInvitationCode',
        {'code': code},
      );

  /// 驗證邀請碼
  _i2.Future<Map<String, dynamic>> validateInvitationCode(
          {required String code}) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'validateInvitationCode',
        {'code': code},
      );

  /// 使用邀請碼
  _i2.Future<Map<String, dynamic>> useInvitationCode({
    required String code,
    required String username,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'useInvitationCode',
        {
          'code': code,
          'username': username,
        },
      );

  /// 註冊用戶
  _i2.Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String name,
    required String role,
    required String building,
    required String unit,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'register',
        {
          'username': username,
          'password': password,
          'name': name,
          'role': role,
          'building': building,
          'unit': unit,
        },
      );

  /// 測試連接
  _i2.Future<Map<String, dynamic>> testConnection() =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'testConnection',
        {},
      );
}

/// This is an example endpoint that returns a greeting message through its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i3.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i3.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i4.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    auth = EndpointAuth(this);
    greeting = EndpointGreeting(this);
  }

  late final EndpointAuth auth;

  late final EndpointGreeting greeting;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'auth': auth,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
