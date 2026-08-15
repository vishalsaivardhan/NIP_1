package com.proxiupi.nip

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel

class BleManager(private val context: Context) {

    companion object {
        private var instance: BleManager? = null
        fun getInstance(context: Context): BleManager {
            if (instance == null) {
                instance = BleManager(context.applicationContext)
            }
            return instance!!
        }
    }

    fun isBluetoothAvailable(): Boolean {
        // TODO: implement real checks using BluetoothAdapter
        Log.d("BleManager", "isBluetoothAvailable called")
        return true
    }

    fun checkPermissions(): Boolean {
        // TODO: implement runtime permission checks
        Log.d("BleManager", "checkPermissions called")
        return true
    }

    fun startScan() {
        Log.d("BleManager", "startScan called")
        // TODO: implement BLE scanning
    }

    fun stopScan() {
        Log.d("BleManager", "stopScan called")
        // TODO: implement stop scanning
    }

    fun startAdvertise() {
        Log.d("BleManager", "startAdvertise called")
        // TODO: implement advertising
    }

    fun stopAdvertise() {
        Log.d("BleManager", "stopAdvertise called")
        // TODO: implement stop advertise
    }

    fun connect(deviceId: String) {
        Log.d("BleManager", "connect to $deviceId")
        // TODO: implement GATT connect
    }

    fun disconnect(deviceId: String) {
        Log.d("BleManager", "disconnect from $deviceId")
        // TODO: implement disconnect
    }

    // Event sink will be populated by MainActivity when Flutter listens
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    fun sendPacket(packetJson: String) {
        Log.d("BleManager", "sendPacket: $packetJson")
        // TODO: send over GATT/characteristic
        // For prototype, echo back after a short delay via eventSink
        eventSink?.success(packetJson)
    }

    fun simulateIncoming(packetJson: String) {
        eventSink?.success(packetJson)
    }
}
