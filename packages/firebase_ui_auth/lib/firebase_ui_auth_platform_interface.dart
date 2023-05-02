import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'firebase_ui_auth_method_channel.dart';

abstract class FirebaseUiAuthPlatform extends PlatformInterface {
  /// Constructs a FirebaseUiAuthPlatform.
  FirebaseUiAuthPlatform() : super(token: _token);

  static final Object _token = Object();

  static FirebaseUiAuthPlatform _instance = MethodChannelFirebaseUiAuth();

  /// The default instance of [FirebaseUiAuthPlatform] to use.
  ///
  /// Defaults to [MethodChannelFirebaseUiAuth].
  static FirebaseUiAuthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FirebaseUiAuthPlatform] when
  /// they register themselves.
  static set instance(FirebaseUiAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>?> getPhoneNumber() {
    throw UnimplementedError('getPhoneNumber() has not been implemented.');
  }
}
