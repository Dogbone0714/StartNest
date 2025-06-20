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
import 'package:community_garden_server_client/src/protocol/greeting.dart'
    as _i3;
import 'protocol.dart' as _i4;

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

/// 認證端點
/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  /// 用戶登入
  _i2.Future<Map<String, dynamic>?> login(String username, String password) =>
      caller.callServerEndpoint<Map<String, dynamic>?>(
        'auth',
        'login',
        {'username': username, 'password': password},
      );

  /// 獲取用戶信息
  _i2.Future<Map<String, dynamic>?> getUserInfo(String username) =>
      caller.callServerEndpoint<Map<String, dynamic>?>(
        'auth',
        'getUserInfo',
        {'username': username},
      );

  /// 獲取所有用戶列表
  _i2.Future<Map<String, dynamic>?> getAllUsers() =>
      caller.callServerEndpoint<Map<String, dynamic>?>(
        'auth',
        'getAllUsers',
        {},
      );

  /// 測試連接
  _i2.Future<Map<String, dynamic>?> testConnection() =>
      caller.callServerEndpoint<Map<String, dynamic>?>(
        'auth',
        'testConnection',
        {},
      );

  /// 新增住戶
  _i2.Future<Map<String, dynamic>> addResident(
    String username,
    String password,
    String name,
    String unit,
  ) =>
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
  _i2.Future<Map<String, dynamic>> deleteResident(String username) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'auth',
        'deleteResident',
        {'username': username},
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
    greeting = EndpointGreeting(this);
    auth = EndpointAuth(this);
  }

  late final EndpointGreeting greeting;
  late final EndpointAuth auth;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'greeting': greeting,
        'auth': auth,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
