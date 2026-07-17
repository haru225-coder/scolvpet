package cn.scolvpet.dev

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Home-screen widget for 今日待办 (T-P1-05).
 * Reads Flutter SharedPreferences written by [SharedPreferencesTodayWidgetPublisher].
 */
class TodayTasksWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_TITLE = "flutter.today_widget_title"
        private const val KEY_BODY = "flutter.today_widget_body"
        private const val KEY_COUNT = "flutter.today_widget_count_label"

        fun requestUpdate(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, TodayTasksWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return
            val intent = Intent(context, TodayTasksWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            context.sendBroadcast(intent)
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val title = prefs.getString(KEY_TITLE, null) ?: "今日待办"
            val body = prefs.getString(KEY_BODY, null) ?: "打开熊舍管家同步任务"
            val count = prefs.getString(KEY_COUNT, null) ?: "—"

            val views = RemoteViews(context.packageName, R.layout.today_tasks_widget).apply {
                setTextViewText(R.id.today_widget_title, title)
                setTextViewText(R.id.today_widget_count, count)
                setTextViewText(R.id.today_widget_body, body)

                val launch = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pending = PendingIntent.getActivity(
                    context,
                    appWidgetId,
                    launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                setOnClickPendingIntent(R.id.today_widget_root, pending)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
