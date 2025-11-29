package com.tlcn.vocaburex

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

// Thêm các import cần thiết cho Intent
import android.content.Intent
import android.app.PendingIntent

class HomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { appWidgetId ->

            // Lấy dữ liệu (như code trước)
            val streakCount = widgetData.getString("streak_count", "0") ?: "0"
            val message = widgetData.getString("widget_message", "Hãy luyện tập nào!") ?: "Hãy luyện tập nào!"
            val trexImageName = widgetData.getString("trex_image", "img_trex_normal") ?: "img_trex_normal"
            val backgroundColorString = widgetData.getString("background_color", "#F778BA") ?: "#F778BA"

            val trexImageResId = context.resources.getIdentifier(trexImageName, "drawable", context.packageName)
            val finalTrexImageResId = if (trexImageResId != 0) trexImageResId else R.drawable.img_trex_normal

            val backgroundColor = try {
                Color.parseColor(backgroundColorString)
            } catch (e: IllegalArgumentException) {
                Color.parseColor("#F778BA")
            }


            // 1. Tạo Intent để mở MainActivity (Flutter Activity)
            // Lấy tên package của ứng dụng Flutter
            val intent = Intent(context, MainActivity::class.java)

            // 2. Tạo PendingIntent
            // FLAG_IMMUTABLE là bắt buộc cho Android 12+
            val pendingIntent = PendingIntent.getActivity(
                context,
                0, // Request Code
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // ----------------------------------------------------

            // 3. Tạo RemoteViews và thiết lập layout
            val views = RemoteViews(context.packageName, R.layout.app_widget_layout).apply {

                // Thiết lập các thông số dữ liệu (như code trước)
                setTextViewText(R.id.widget_streak_count, streakCount)
                setTextViewText(R.id.widget_message_text, message)
                setImageViewResource(R.id.widget_trex_image, finalTrexImageResId)
                setInt(R.id.widget_background_frame, "setBackgroundColor", backgroundColor)
                setTextViewText(R.id.widget_app_name, "VocabuRex")

                // 4. Gán PendingIntent cho TOÀN BỘ Widget (R.id.widget_background_frame)
                setOnClickPendingIntent(R.id.widget_background_frame, pendingIntent)
            }

            // 5. Cập nhật widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}