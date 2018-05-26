package com.msasikanth.newsapp

import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.support.customtabs.CustomTabsIntent
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {

    private val ANDROID = "com.msasikanth.newsapp/android"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, ANDROID).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "launchUrl") {
                val url = methodCall.argument<String>("url")
                launchUrl(url)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun launchUrl(url: String) {
        val builder = CustomTabsIntent.Builder()
        builder.setToolbarColor(Color.BLACK)
        val customTabsIntent = builder.build()
        customTabsIntent.launchUrl(this, Uri.parse(url))
    }

}
