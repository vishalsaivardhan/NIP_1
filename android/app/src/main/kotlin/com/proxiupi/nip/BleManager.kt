package com.proxiupi.nip

import android.annotation.TargetApi
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.nio.charset.Charset
import java.util.*

class BleManager(private val context: Context) {

    private val TAG = "BleManager"

    private val bluetoothManager: BluetoothManager? = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
    private val bluetoothAdapter: BluetoothAdapter? = bluetoothManager?.adapter
    private var advertiser: BluetoothLeAdvertiser? = bluetoothAdapter?.bluetoothLeAdvertiser
    private var scanner: BluetoothLeScanner? = bluetoothAdapter?.bluetoothLeScanner

    private var gattServer: BluetoothGattServer? = null
    private val connectedClients: MutableMap<String, BluetoothGatt> = mutableMapOf()

    // Service & characteristic UUIDs (fixed for prototype)
    private val SERVICE_UUID: UUID = UUID.fromString("0000feed-0000-1000-8000-00805f9b34fb")
    private val CHARACTERISTIC_UUID: UUID = UUID.fromString("0000beef-0000-1000-8000-00805f9b34fb")

    companion object {
        private var instance: BleManager? = null
        var eventSink: EventChannel.EventSink? = null

        fun getInstance(context: Context): BleManager {
            if (instance == null) {
                instance = BleManager(context.applicationContext)
            }
            return instance!!
        }
    }

    fun isBluetoothAvailable(): Boolean {
        val available = bluetoothAdapter?.isEnabled == true
        Log.d(TAG, "isBluetoothAvailable: $available")
        return available
    }

    fun checkPermissions(): Boolean {
        // Runtime permissions should be managed by the Flutter layer; assume granted for prototype
        Log.d(TAG, "checkPermissions called")
        return true
    }

    fun startAdvertise() {
        if (advertiser == null) {
            Log.w(TAG, "Advertiser not available")
            return
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build()

        val data = AdvertiseData.Builder()
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .setIncludeDeviceName(true)
            .build()

        advertiser?.startAdvertising(settings, data, advertiseCallback)
        Log.d(TAG, "startAdvertise started")
        // ensure GATT server running to accept writes
        startGattServer()
    }

    fun stopAdvertise() {
        advertiser?.stopAdvertising(advertiseCallback)
        Log.d(TAG, "stopAdvertise")
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            Log.d(TAG, "Advertise onStartSuccess")
        }

        override fun onStartFailure(errorCode: Int) {
            Log.w(TAG, "Advertise onStartFailure: $errorCode")
        }
    }

    fun startScan() {
        if (scanner == null) {
            Log.w(TAG, "Scanner not available")
            return
        }
        val filter = ScanFilter.Builder().setServiceUuid(ParcelUuid(SERVICE_UUID)).build()
        val settings = ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()
        scanner?.startScan(listOf(filter), settings, scanCallback)
        Log.d(TAG, "startScan started")
    }

    fun stopScan() {
        scanner?.stopScan(scanCallback)
        Log.d(TAG, "stopScan")
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device
            Log.d(TAG, "Scan found device: ${device.address} / ${device.name}")
            // Auto-connect to discovered device (prototype)
            if (!connectedClients.containsKey(device.address)) {
                device.connectGatt(context, false, gattClientCallback)
            }
        }
    }

    fun connect(deviceId: String) {
        // Attempt to connect to known device by address
        val device = bluetoothAdapter?.getRemoteDevice(deviceId)
        if (device != null && !connectedClients.containsKey(device.address)) {
            device.connectGatt(context, false, gattClientCallback)
            Log.d(TAG, "connect requested to $deviceId")
        }
    }

    fun disconnect(deviceId: String) {
        connectedClients[deviceId]?.disconnect()
        connectedClients.remove(deviceId)
        Log.d(TAG, "disconnect requested for $deviceId")
    }

    private val gattClientCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            super.onConnectionStateChange(gatt, status, newState)
            val addr = gatt.device.address
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.d(TAG, "Client connected: $addr")
                connectedClients[addr] = gatt
                gatt.discoverServices()
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.d(TAG, "Client disconnected: $addr")
                connectedClients.remove(addr)
                gatt.close()
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            super.onServicesDiscovered(gatt, status)
            Log.d(TAG, "Services discovered for ${gatt.device.address}")
        }
    }

    private fun startGattServer() {
        if (gattServer != null) return
        val mgr = bluetoothManager ?: return
        gattServer = mgr.openGattServer(context, gattServerCallback)

        val service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        val char = BluetoothGattCharacteristic(
            CHARACTERISTIC_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )
        service.addCharacteristic(char)
        gattServer?.addService(service)
        Log.d(TAG, "GATT server started")
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            super.onConnectionStateChange(device, status, newState)
            Log.d(TAG, "GATT server conn state change: ${device.address} -> $newState")
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            super.onCharacteristicWriteRequest(device, requestId, characteristic, preparedWrite, responseNeeded, offset, value)
            val payload = String(value, Charset.forName("UTF-8"))
            Log.d(TAG, "GATT write from ${device.address}: $payload")
            Handler(Looper.getMainLooper()).post {
                eventSink?.success(payload)
            }
            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
            }
        }
    }

    fun sendPacket(packetJson: String) {
        Log.d(TAG, "sendPacket to connected clients: $packetJson")
        val bytes = packetJson.toByteArray(Charset.forName("UTF-8"))
        // Write to all connected client GATTs if they have the service/characteristic
        for ((addr, gatt) in connectedClients) {
            val svc = gatt.getService(SERVICE_UUID)
            if (svc == null) continue
            val char = svc.getCharacteristic(CHARACTERISTIC_UUID) ?: continue
            char.value = bytes
            val ok = gatt.writeCharacteristic(char)
            Log.d(TAG, "writeCharacteristic to $addr success=$ok")
        }
        // For local testing, also emit to Flutter
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(packetJson)
        }
    }

    fun simulateIncoming(packetJson: String) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(packetJson)
        }
    }
}
