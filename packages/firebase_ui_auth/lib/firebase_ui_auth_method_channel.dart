import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'firebase_ui_auth_platform_interface.dart';

/// An implementation of [FirebaseUiAuthPlatform] that uses method channels.
class MethodChannelFirebaseUiAuth extends FirebaseUiAuthPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('firebase_ui_auth');

  @override
  Future<Map<String, dynamic>?> getPhoneNumber() async {
    return (await methodChannel.invokeMethod<Map>('getPhoneNumber'))
        ?.cast<String, dynamic>();
  }
}
