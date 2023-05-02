package io.flutter.plugins.firebase.ui_auth

import android.app.Activity.RESULT_OK
import android.app.PendingIntent
import android.content.Intent
import com.google.android.gms.auth.api.identity.GetPhoneNumberHintIntentRequest
import com.google.android.gms.auth.api.identity.Identity
import com.google.i18n.phonenumbers.PhoneNumberUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class FirebaseUiAuthPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private lateinit var channel : MethodChannel
  private lateinit var activityPluginBinding: ActivityPluginBinding
  private var pendingResult: Result? = null

  companion object {
    const val REQUEST_CODE = 2523
    val phoneUtil: PhoneNumberUtil = PhoneNumberUtil.getInstance()
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "firebase_ui_auth")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    attachActivityPluginBinding(binding)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    attachActivityPluginBinding(binding)
  }

  private fun attachActivityPluginBinding(binding: ActivityPluginBinding) {
    activityPluginBinding = binding
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    disposeActivityPluginBinding()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    disposeActivityPluginBinding()
  }

  private fun disposeActivityPluginBinding() {
    activityPluginBinding.removeActivityResultListener(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPhoneNumber" -> getPhoneNumberHint(result)
      else -> result.notImplemented()
    }
  }

  private fun getPhoneNumberHint(result: Result) {
    pendingResult = result
    val activity = activityPluginBinding.activity

    val request: GetPhoneNumberHintIntentRequest = GetPhoneNumberHintIntentRequest.builder()
      .build()

    Identity.getSignInClient(activity)
      .getPhoneNumberHintIntent(request)
      .addOnSuccessListener { intent: PendingIntent ->
        activity.startIntentSenderForResult(
          intent.intentSender,
          REQUEST_CODE,
          null,
          0,
          0,
          0,
          null
        )
      }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode != REQUEST_CODE || resultCode != RESULT_OK) {
      pendingResult?.success(null)
      pendingResult = null
      return false
    }

    val d = data ?: run {
      pendingResult?.success(null)
      pendingResult = null
      return false
    }

    val phone = Identity.getSignInClient(activityPluginBinding.activity)
      .getPhoneNumberFromIntent(d)

    val phoneNumber = phoneUtil.parse(phone, "US")
    val map = HashMap<String, Any>()
    map["countryCode"] = phoneNumber.countryCode
    map["nationalNumber"] = phoneNumber.nationalNumber

    pendingResult?.success(map)
    return true
  }
}
