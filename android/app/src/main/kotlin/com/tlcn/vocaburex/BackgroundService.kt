package com.tlcn.vocaburex

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import androidx.core.app.NotificationCompat

class BackgroundService : Service() {

    private val CHANNEL_ID = "vocaburex_bg_channel"
    private val NOTIF_ID = 888
    private var handler: Handler? = null

    // Tạo Binder để Activity kết nối vào
    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): BackgroundService = this@BackgroundService
    }

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Mặc định cứ hiện thông báo trước để đảm bảo service sống
        showNotification("Service đang chạy ngầm...")
        startLoop()
        return START_STICKY
    }

    // --- 1. KHI APP KẾT NỐI (Mở App) ---
    override fun onBind(intent: Intent?): IBinder {
        // Khi App mở lên và bind vào, ta ẩn thông báo đi cho đỡ vướng
        stopForeground(STOP_FOREGROUND_REMOVE)
        return binder
    }

    // --- 2. KHI APP NGẮT KẾT NỐI (Ẩn App / Home) ---
    override fun onUnbind(intent: Intent?): Boolean {
        // Khi App ẩn đi, ta phải hiện thông báo lại ngay lập tức để giữ Service sống
        showNotification("VocabuRex đang chạy ngầm...")
        return true // Trả về true để lần sau bind lại nó gọi onRebind
    }

    override fun onRebind(intent: Intent?) {
        super.onRebind(intent)
        // Bind lại lần nữa (mở lại app từ background) -> Ẩn thông báo
        stopForeground(STOP_FOREGROUND_REMOVE)
    }

    // --- 3. KHI APP BỊ KILL (Vuốt tắt) ---
    override fun onTaskRemoved(rootIntent: Intent?) {
        // Đảm bảo thông báo hiện lên khi app bị kill
        showNotification("VocabuRex vẫn đang chạy...")

        // Hồi sinh service (Logic cũ)
        val restartServiceIntent = Intent(applicationContext, BackgroundService::class.java).also {
            it.setPackage(packageName)
        }
        val restartServicePendingIntent = PendingIntent.getService(
            this, 1, restartServiceIntent, PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmService = applicationContext.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
        alarmService.set(
            android.app.AlarmManager.ELAPSED_REALTIME,
            SystemClock.elapsedRealtime() + 1000,
            restartServicePendingIntent
        )
        super.onTaskRemoved(rootIntent)
    }

    // --- Logic Loop (Giữ nguyên) ---
    private fun startLoop() {
        if (handler == null) handler = Handler(Looper.getMainLooper())
        val runnable = object : Runnable {
            override fun run() {
                val timeString = java.text.SimpleDateFormat("HH:mm:ss").format(java.util.Date())
                println("Background Running: $timeString")
                // Nếu đang chạy foreground (có thông báo) thì update text
                // Nếu đang ẩn thông báo thì thôi
                handler?.postDelayed(this, 10000)
            }
        }
        handler?.post(runnable)
    }

    // --- Helper functions ---
    private fun showNotification(text: String) {
        // Hàm này gọi startForeground để hiện thông báo
        startForeground(NOTIF_ID, buildNotification(text))
    }

    private fun buildNotification(text: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("VocabuRex")
            .setContentText(text)
            .setSmallIcon(R.mipmap.ic_launcher) // Đổi thành icon drawable của bạn
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "Background Service", NotificationManager.IMPORTANCE_LOW)
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }
}