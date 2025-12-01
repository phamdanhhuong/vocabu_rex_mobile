package com.tlcn.vocaburex

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity(){
    // Biến để quản lý kết nối Service
    private var mService: BackgroundService? = null
    private var mBound = false

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
