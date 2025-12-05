package com.tlcn.vocaburex

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity(){
    // Biến để quản lý kết nối Service
    private var mService: BackgroundService? = null
    private var mBound = false

    //
    private val CHANNEL = "com.tlcn.vocaburex/native_service"

    //
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "syncStreak") {
                // 1. Lấy chuỗi JSON từ Flutter gửi sang
                val data = call.argument<String>("data")

                if (data != null) {
                    // 2. Lưu vào SharedPreferences
                    saveDataToPrefs(data)
                    result.success("Synced")
                } else {
                    result.error("ERROR", "Data is null", null)
                }
            }
            // ... giữ các method startService/stopService cũ ...
            else {
                result.notImplemented()
            }
        }
    }

    private fun saveDataToPrefs(jsonString: String) {
        val sharedPref = getSharedPreferences("VocabuRexPrefs", Context.MODE_PRIVATE)
        with (sharedPref.edit()) {
            putString("streak_data", jsonString)
            apply() // Lưu bất đồng bộ
        }
    }

    // Định nghĩa việc kết nối
    private val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as BackgroundService.LocalBinder
            mService = binder.getService()
            mBound = true
        }

        override fun onServiceDisconnected(arg0: ComponentName) {
            mBound = false
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 1. Vẫn gọi Start Service để đảm bảo nó chạy bền bỉ
        val intent = Intent(this, BackgroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    override fun onStart() {
        super.onStart()
        // 2. KHI MỞ APP: Bind vào service -> Service sẽ tự ẩn thông báo
        Intent(this, BackgroundService::class.java).also { intent ->
            bindService(intent, connection, Context.BIND_AUTO_CREATE)
        }
    }

    override fun onStop() {
        super.onStop()
        // 3. KHI TẮT/ẨN APP: Unbind -> Service sẽ tự hiện thông báo lại
        if (mBound) {
            unbindService(connection)
            mBound = false
        }
    }
}
