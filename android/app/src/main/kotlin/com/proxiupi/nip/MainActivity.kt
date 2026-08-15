package com.proxiupi.nip

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "proxiupi/ble"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		val bleManager = BleManager.getInstance(this)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"isBluetoothAvailable" -> result.success(bleManager.isBluetoothAvailable())
				"checkPermissions" -> result.success(bleManager.checkPermissions())
				"startScan" -> {
					bleManager.startScan(); result.success(null)
				}
				"stopScan" -> {
					bleManager.stopScan(); result.success(null)
				}
				"startAdvertise" -> {
					bleManager.startAdvertise(); result.success(null)
				}
				"stopAdvertise" -> {
					bleManager.stopAdvertise(); result.success(null)
				}
				"connect" -> {
					val deviceId = call.argument<String>("deviceId") ?: ""
					bleManager.connect(deviceId); result.success(null)
				}
				"disconnect" -> {
					val deviceId = call.argument<String>("deviceId") ?: ""
					bleManager.disconnect(deviceId); result.success(null)
				}
				else -> result.notImplemented()
			}
		}
	}
}
