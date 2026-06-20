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
import java.util.Calendar
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
                handler?.postDelayed(this, 3600000) // 1 Tiếng
            }
        }
        handler?.post(runnable)
    }

    // --- LOGIC CHÍNH: KIỂM TRA NGÀY HỌC ---
    private fun checkStudyStatusAndNotify() {
        val sharedPref = getSharedPreferences("VocabuRexPrefs", Context.MODE_PRIVATE)
        
        val streakJsonStr = sharedPref.getString("streak_data", null)
        val profileJsonStr = sharedPref.getString("profile_data", null)
        val activityJsonStr = sharedPref.getString("activity_data", null)

        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val todayStr = sdf.format(Date())
        
        // Cấu hình mặc định
        var dailyGoalMinutes = 15
        var displayName = "bạn"
        var streakDays = 0
        var totalExp = 0
        
        // Trạng thái hôm nay
        var todayMinutes = 0
        var hasStudiedToday = false

        // Đọc Profile
        if (profileJsonStr != null) {
            try {
                val profileObj = JSONObject(profileJsonStr)
                dailyGoalMinutes = profileObj.optInt("dailyGoalMinutes", 15)
                displayName = profileObj.optString("displayName", "bạn")
                streakDays = profileObj.optInt("streakDays", 0)
                totalExp = profileObj.optInt("totalExp", 0)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // Đọc Activity
        if (activityJsonStr != null) {
            try {
                val activityObj = JSONObject(activityJsonStr)
                val actDate = activityObj.optString("date", "")
                if (actDate == todayStr) {
                    todayMinutes = activityObj.optInt("todayMinutes", 0)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // Đọc Streak (cũ)
        if (streakJsonStr != null) {
            try {
                val jsonObject = JSONObject(streakJsonStr)
                val currentStreakObj = jsonObject.getJSONObject("currentStreak")
                val lastStudyDateStr = currentStreakObj.optString("lastStudyDate", "")
                val lastStudyDayOnly = if (lastStudyDateStr.length >= 10) lastStudyDateStr.substring(0, 10) else ""
                
                if (lastStudyDayOnly == todayStr) {
                    hasStudiedToday = true
                }
                
                // Nếu profile chưa có streakDays, lấy từ streak_data
                if (streakDays == 0) {
                    streakDays = currentStreakObj.optInt("length", 0)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // Quyết định thông báo
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        var message = ""
        
        // 1. Kiểm tra Breakthrough: Streak Milestones
        val milestones = listOf(7, 14, 30, 50, 100, 365)
        if (hasStudiedToday && milestones.contains(streakDays)) {
            val lastMilestoneNotif = sharedPref.getString("last_milestone_notif", "")
            if (lastMilestoneNotif != "$todayStr-$streakDays") {
                message = "\uD83C\uDFC6 WOW! Chúc mừng bạn đạt Streak $streakDays ngày liên tiếp!"
                sharedPref.edit().putString("last_milestone_notif", "$todayStr-$streakDays").apply()
            }
        }

        // 2. Logic theo thời gian trong ngày (nếu chưa có message từ breakthrough)
        if (message.isEmpty()) {
            if (todayMinutes >= dailyGoalMinutes) {
                // Đã đạt mục tiêu
                message = "\uD83C\uDF89 Tuyệt vời $displayName! Bạn đã đạt mục tiêu $dailyGoalMinutes phút hôm nay! (Streak: $streakDays \uD83D\uDD25)"
            } else if (hasStudiedToday) {
                // Đã học nhưng chưa đủ mục tiêu
                val percent = (todayMinutes * 100) / dailyGoalMinutes
                message = "\uD83D\uDCAA Bạn đã hoàn thành $percent% mục tiêu hôm nay ($todayMinutes/$dailyGoalMinutes phút). Tiếp tục nhé!"
            } else {
                // Chưa học
                when (hour) {
                    in 8..11 -> message = "☀️ Chào buổi sáng $displayName! Mục tiêu hôm nay là $dailyGoalMinutes phút. Bắt đầu ngay thôi!"
                    in 12..17 -> message = "\uD83D\uDCDA Tranh thủ học từ vựng lúc rảnh rỗi nhé $displayName! Cần $dailyGoalMinutes phút để đạt mục tiêu."
                    in 18..21 -> message = "⚠️ Bạn chưa học hôm nay! Dành ra $dailyGoalMinutes phút buổi tối để giữ streak $streakDays ngày nhé."
                    in 22..23 -> message = "\uD83D\uDEA8 Sắp qua ngày mới rồi! Vào học ngay kẻo mất chuỗi $streakDays ngày liên tiếp!"
                    else -> message = "Ngủ ngon nhé! Đừng quên lịch học từ vựng ngày mai." // 0-7h
                }
            }
        }

        // 3. Anti-Spam: Đừng thông báo y hệt nếu đã hiện trong 2 tiếng qua
        val lastNotifMsg = sharedPref.getString("last_notif_msg", "")
        val lastNotifTime = sharedPref.getLong("last_notif_time", 0)
        val now = System.currentTimeMillis()
        
        // Nếu tin nhắn không đổi và chưa qua 3 tiếng, thì giữ nguyên không cập nhật
        if (message == lastNotifMsg && (now - lastNotifTime) < 3 * 60 * 60 * 1000) {
            // Không spam thông báo y hệt
            // Nhưng service foreground vẫn cần showNotification để sống sót
            showNotification(message)
            return
        }
        
        sharedPref.edit()
            .putString("last_notif_msg", message)
            .putLong("last_notif_time", now)
            .apply()

        showNotification(message)
    }

    // --- HELPER FUNCTIONS ---
    private fun showNotification(text: String) {
        startForeground(NOTIF_ID, buildNotification(text))
    }

    private fun buildNotification(text: String): Notification {
        // Tạo intent để mở MainActivity khi click vào thông báo
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this, 0, intent, PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("VocabuRex")
            .setContentText(text)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text)) // Để text dài hiển thị đầy đủ
            .setOngoing(true)
            .setOnlyAlertOnce(true) // Tránh rung màn hình/kêu lại liên tục nếu cùng nội dung
            .build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "VocabuRex Reminder", NotificationManager.IMPORTANCE_DEFAULT)
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }
}