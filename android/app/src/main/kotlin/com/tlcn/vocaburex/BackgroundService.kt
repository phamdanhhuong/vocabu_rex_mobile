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
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class BackgroundService : Service() {

    private val CHANNEL_ID = "vocaburex_bg_channel"
    private val NOTIF_ID = 888
    private var handler: Handler? = null

    // Binder
    private val binder = LocalBinder()
    inner class LocalBinder : Binder() {
        fun getService(): BackgroundService = this@BackgroundService
    }

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Khởi động service, check ngay lần đầu tiên
        checkStudyStatusAndNotify()
        startLoop()
        return START_STICKY
    }

    // --- BINDING LOGIC ---
    override fun onBind(intent: Intent?): IBinder {
        stopForeground(STOP_FOREGROUND_REMOVE)
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        // Khi tắt app, check ngay lập tức để hiện thông báo đúng trạng thái
        checkStudyStatusAndNotify()
        return true
    }

    override fun onRebind(intent: Intent?) {
        super.onRebind(intent)
        stopForeground(STOP_FOREGROUND_REMOVE)
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Khi user kill app, check và hiện thông báo
        checkStudyStatusAndNotify()

        // Hồi sinh service
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

    // --- VÒNG LẶP CHECK DATA ---
    private fun startLoop() {
        if (handler == null) handler = Handler(Looper.getMainLooper())

        val runnable = object : Runnable {
            override fun run() {
                // Logic kiểm tra và thông báo
                checkStudyStatusAndNotify()

                // Lặp lại sau 1 Tiếng (60 phút * 60 giây * 1000 ms)
                //handler?.postDelayed(this, 10 * 1000) // Dùng dòng này nếu muốn test nhanh 10s
                handler?.postDelayed(this, 3600000) // 1 Tiếng
            }
        }
        handler?.post(runnable)
    }

    // --- LOGIC CHÍNH: KIỂM TRA NGÀY HỌC ---
    private fun checkStudyStatusAndNotify() {
        val sharedPref = getSharedPreferences("VocabuRexPrefs", Context.MODE_PRIVATE)
        val jsonString = sharedPref.getString("streak_data", null)

        if (jsonString == null) {
            // Chưa có dữ liệu -> Nhắc vào học
            showNotification("Bạn chưa có dữ liệu học tập. Vào học ngay nhé! \uD83D\uDCDA")
            return
        }

        try {
            val jsonObject = JSONObject(jsonString)
            val currentStreakObj = jsonObject.getJSONObject("currentStreak")

            // 1. Lấy ngày học cuối cùng từ JSON (Dạng chuỗi ISO: "2023-10-25T14:30:00...")
            val lastStudyDateStr = currentStreakObj.optString("lastStudyDate", "")

            // 2. Lấy ngày hôm nay
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            val todayStr = sdf.format(Date())

            // 3. So sánh
            // Cắt chuỗi lastStudyDate chỉ lấy 10 ký tự đầu (yyyy-MM-dd) để so sánh
            val lastStudyDayOnly = if (lastStudyDateStr.length >= 10) lastStudyDateStr.substring(0, 10) else ""

            if (lastStudyDayOnly == todayStr) {
                // Đã học hôm nay
                val streakDays = currentStreakObj.optInt("length", 0)
                // Tùy chọn: Có thể hiện thông báo khen ngợi hoặc im lặng
                showNotification("Bạn đã hoàn thành bài học hôm nay! (Streak: $streakDays \uD83D\uDD25)")
            } else {
                // Chưa học hôm nay (hoặc lastStudyDate là null/rỗng)
                val streakDays = currentStreakObj.optInt("length", 0)
                showNotification("⚠\uFE0F Bạn quên học hôm nay rồi! Vào giữ Streak $streakDays ngày ngay!")
            }

        } catch (e: Exception) {
            e.printStackTrace()
            showNotification("Đã đến giờ học từ vựng rồi! \uD83D\uDE80")
        }
    }

    // --- HELPER FUNCTIONS ---
    private fun showNotification(text: String) {
        startForeground(NOTIF_ID, buildNotification(text))
    }

    private fun buildNotification(text: String): Notification {
        // Lưu ý: Đảm bảo bạn có file icon trong res/drawable hoặc mipmap
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("VocabuRex Nhắc Nhở")
            .setContentText(text)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(false) // Để false để mỗi tiếng nó rung/kêu 1 lần nhắc nhở
            .build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Đổi importance lên HIGH hoặc DEFAULT để người dùng dễ thấy hơn
            val channel = NotificationChannel(CHANNEL_ID, "VocabuRex Reminder", NotificationManager.IMPORTANCE_DEFAULT)
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }
}