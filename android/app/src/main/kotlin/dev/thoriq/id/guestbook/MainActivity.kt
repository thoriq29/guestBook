package dev.thoriq.id.guestbook

import android.os.Bundle

import io.flutter.app.FlutterActivity
import android.content.pm.PackageManager;
import io.flutter.plugins.GeneratedPluginRegistrant
import android.Manifest;
import android.os.Build;

class MainActivity: FlutterActivity() {
  var PERMISSION_ALL = 1
var PERMISSIONS = arrayOf<String>(Manifest.permission.RECORD_AUDIO, Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.WRITE_EXTERNAL_STORAGE)
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }
  private fun requestRequiredPermissions() {
  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
  {
    if (checkCallingOrSelfPermission(Manifest.permission.RECORD_AUDIO) === PackageManager.PERMISSION_DENIED || checkCallingOrSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) === PackageManager.PERMISSION_DENIED || checkCallingOrSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) === PackageManager.PERMISSION_DENIED)
    {
      requestPermissions(PERMISSIONS, PERMISSION_ALL)
    }
  }
}
}
