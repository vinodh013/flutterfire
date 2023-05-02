import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth_platform_interface.dart';
import 'package:firebase_ui_auth/firebase_ui_auth_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFirebaseUiAuthPlatform
    with MockPlatformInterfaceMixin
    implements FirebaseUiAuthPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FirebaseUiAuthPlatform initialPlatform = FirebaseUiAuthPlatform.instance;

  test('$MethodChannelFirebaseUiAuth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFirebaseUiAuth>());
  });

  test('getPlatformVersion', () async {
    FirebaseUiAuth firebaseUiAuthPlugin = FirebaseUiAuth();
    MockFirebaseUiAuthPlatform fakePlatform = MockFirebaseUiAuthPlatform();
    FirebaseUiAuthPlatform.instance = fakePlatform;

    expect(await firebaseUiAuthPlugin.getPlatformVersion(), '42');
  });
}
