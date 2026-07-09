package com.kevin.astral

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF

object WidgetBitmapFactory {
    private const val CARD_WIDTH_DP = 360
    private const val CARD_HEIGHT_DP = 240
    private const val CHIP_WIDTH_DP = 320
    private const val CHIP_HEIGHT_DP = 56

    fun cardBackground(context: Context, color: Int): Bitmap {
        val radius = context.resources.getDimension(R.dimen.widget_corner_radius)
        return roundedRect(
            context = context,
            color = color,
            widthDp = CARD_WIDTH_DP,
            heightDp = CARD_HEIGHT_DP,
            cornerRadiusPx = radius,
            strokeColor = 0x14000000,
        )
    }

    fun chipBackground(context: Context, color: Int): Bitmap {
        val radius = context.resources.getDimension(R.dimen.widget_inner_corner_radius)
        return roundedRect(
            context = context,
            color = color,
            widthDp = CHIP_WIDTH_DP,
            heightDp = CHIP_HEIGHT_DP,
            cornerRadiusPx = radius,
            strokeColor = null,
        )
    }

    private fun roundedRect(
        context: Context,
        color: Int,
        widthDp: Int,
        heightDp: Int,
        cornerRadiusPx: Float,
        strokeColor: Int?,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val width = (widthDp * density).toInt().coerceAtLeast(2)
        val height = (heightDp * density).toInt().coerceAtLeast(2)
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color }
        val rect = RectF(0f, 0f, width.toFloat(), height.toFloat())
        canvas.drawRoundRect(rect, cornerRadiusPx, cornerRadiusPx, paint)
        if (strokeColor != null) {
            val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                this.color = strokeColor
                strokeWidth = density
            }
            val inset = stroke.strokeWidth / 2f
            canvas.drawRoundRect(
                RectF(inset, inset, width - inset, height - inset),
                cornerRadiusPx,
                cornerRadiusPx,
                stroke,
            )
        }
        return bitmap
    }
}
