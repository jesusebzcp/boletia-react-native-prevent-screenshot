package com.preventscreenshot

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.Base64
import android.util.Log
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.ImageView
import android.widget.RelativeLayout
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import java.io.IOException
import java.net.URL

class PreventScreenshotModule(reactContext: ReactApplicationContext) :
        ReactContextBaseJavaModule(reactContext), LifecycleEventListener {

  private var overlayLayout: RelativeLayout? = null
  private var secureFlagWasSet: Boolean = false

  init {
    reactContext.addLifecycleEventListener(this)
  }

  override fun getName(): String {
    return "RNScreenshotPrevent"
  }

  @ReactMethod
  fun enabled(enable: Boolean) {
    currentActivity?.let { activity ->
      activity.runOnUiThread {
        if (enable) {
          activity.window.setFlags(
                  WindowManager.LayoutParams.FLAG_SECURE,
                  WindowManager.LayoutParams.FLAG_SECURE
          )
        } else {
          activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
      }
    }
  }

  @ReactMethod
  fun enableSecureView(imageData: String) {
    currentActivity?.let { activity ->
      if (overlayLayout == null) {
        if (imageData.startsWith("data:image")) {
          Log.d("PreventScreenshot", "Processing Base64 image")
          createOverlayFromBase64(activity, imageData)
        } else {
          Log.d("PreventScreenshot", "Processing image from URL")
          createOverlay(activity, imageData)
        }
      }
      activity.runOnUiThread {
        activity.window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
        )
      }
    }
  }

  @ReactMethod
  fun disableSecureView() {
    currentActivity?.let { activity ->
      activity.runOnUiThread {
        overlayLayout?.let {
          val rootView = activity.window.decorView.rootView as ViewGroup
          rootView.removeView(overlayLayout)
          overlayLayout = null
        }
        activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
      }
    }
  }

  private fun createOverlayFromBase64(activity: Activity, base64ImageData: String) {
    val base64Data = base64ImageData.substringAfter("base64,")
    val imageBytes = Base64.decode(base64Data, Base64.DEFAULT)

    // Convertir los bytes en un Bitmap
    val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

    if (bitmap == null) {
      Log.e("PreventScreenshot", "Failed to decode base64 image")
      return
    } else {
      Log.d("PreventScreenshot", "Successfully decoded base64 image")
    }

    // Crear el overlay
    overlayLayout =
            RelativeLayout(activity).apply { setBackgroundColor(Color.parseColor("#FFFFFF")) }

    val imageView = ImageView(activity)
    val imageParams =
            RelativeLayout.LayoutParams(
                            RelativeLayout.LayoutParams.MATCH_PARENT,
                            RelativeLayout.LayoutParams.WRAP_CONTENT
                    )
                    .apply { addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE) }

    imageView.layoutParams = imageParams

    // Ajustar el tamaño de la imagen si es muy grande
    val scaledBitmap =
            Bitmap.createScaledBitmap(
                    bitmap,
                    activity.resources.displayMetrics.widthPixels,
                    (bitmap.height *
                                    (activity.resources.displayMetrics.widthPixels.toFloat() /
                                            bitmap.width))
                            .toInt(),
                    true
            )

    imageView.setImageBitmap(scaledBitmap)
    imageView.scaleType =
            ImageView.ScaleType
                    .FIT_CENTER // Ajustamos la imagen para que se ajuste al tamaño disponible

    overlayLayout?.addView(imageView)

    // Asegurarnos de agregar la vista al root view
    activity.runOnUiThread {
      val rootView = activity.window.decorView.rootView as ViewGroup
      rootView.addView(overlayLayout)
      Log.d("PreventScreenshot", "Overlay added to root view")
    }
  }

  private fun createOverlay(activity: Activity, imagePath: String) {
    overlayLayout =
            RelativeLayout(activity).apply { setBackgroundColor(Color.parseColor("#FFFFFF")) }

    val imageView = ImageView(activity)
    val imageParams =
            RelativeLayout.LayoutParams(
                            RelativeLayout.LayoutParams.MATCH_PARENT,
                            RelativeLayout.LayoutParams.WRAP_CONTENT
                    )
                    .apply { addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE) }

    imageView.layoutParams = imageParams
    val bitmap = decodeImageUrl(imagePath)

    if (bitmap != null) {
      Log.d("PreventScreenshot", "Image from URL decoded successfully")
    } else {
      Log.e("PreventScreenshot", "Failed to decode image from URL")
      return
    }

    val imageHeight =
            (bitmap.height *
                            (activity.resources.displayMetrics.widthPixels.toFloat() /
                                    bitmap.width))
                    .toInt()
    val scaledBitmap =
            Bitmap.createScaledBitmap(
                    bitmap,
                    activity.resources.displayMetrics.widthPixels,
                    imageHeight,
                    true
            )
    imageView.setImageBitmap(scaledBitmap)

    overlayLayout?.addView(imageView)

    // Asegurarnos de agregar la vista al root view
    activity.runOnUiThread {
      val rootView = activity.window.decorView.rootView as ViewGroup
      rootView.addView(overlayLayout)
      Log.d("PreventScreenshot", "Overlay added to root view")
    }
  }

  private fun decodeImageUrl(imagePath: String): Bitmap? {
    return try {
      val imageUrl = URL(imagePath)
      BitmapFactory.decodeStream(imageUrl.openConnection().getInputStream())
    } catch (e: IOException) {
      e.printStackTrace()
      null
    }
  }

  override fun onHostResume() {
    currentActivity?.let { activity ->
      if (overlayLayout != null) {
        activity.runOnUiThread {
          val rootView = activity.window.decorView.rootView as ViewGroup
          rootView.removeView(overlayLayout)
          if (secureFlagWasSet) {
            activity.window.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
            )
            secureFlagWasSet = false
          }
        }
      }
    }
  }

  override fun onHostPause() {
    currentActivity?.let { activity ->
      if (overlayLayout != null) {
        activity.runOnUiThread {
          val rootView = activity.window.decorView.rootView as ViewGroup
          val layoutParams =
                  RelativeLayout.LayoutParams(
                          ViewGroup.LayoutParams.MATCH_PARENT,
                          ViewGroup.LayoutParams.MATCH_PARENT
                  )
          rootView.addView(overlayLayout, layoutParams)

          val flags = activity.window.attributes.flags
          if ((flags and WindowManager.LayoutParams.FLAG_SECURE) != 0) {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            secureFlagWasSet = true
          } else {
            secureFlagWasSet = false
          }
        }
      }
    }
  }

  override fun onHostDestroy() {
    // Limpieza si es necesario
  }
}
