package com.saransa.game_app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import com.unity3d.player.IUnityPlayerLifecycleEvents
import com.unity3d.player.UnityPlayer
import com.unity3d.player.UnityPlayerForActivityOrService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity : FlutterActivity(), IUnityPlayerLifecycleEvents {
    private val CHANNEL = "com.saransa"
    private var unityPlayer: UnityPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the UnityView factory
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("UnityView", UnityViewFactory(this))

        // Set up MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadScene" -> {
                    val sceneName = call.argument<String>("sceneName")
                    if (sceneName != null) {
                        loadUnityScene(sceneName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Scene name is null", null)
                    }
                }
                "unloadScene" -> {
                    unloadUnityScene()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun loadUnityScene(sceneName: String) {
        UnityPlayer.UnitySendMessage("SceneLoader", "LoadScene", sceneName)
    }

    private fun unloadUnityScene() {
        UnityPlayer.UnitySendMessage("SceneLoader", "UnloadScene", "")
    }

    // Pass lifecycle events to UnityPlayer
    override fun onResume() {
        super.onResume()
        unityPlayer?.resume()
    }

    override fun onPause() {
        super.onPause()
        unityPlayer?.pause()
    }

    override fun onDestroy() {
        unityPlayer?.destroy()
        super.onDestroy()
    }

    override fun onLowMemory() {
        super.onLowMemory()
        // unityPlayer?.lowMemory() // Not available in this abstract class version
    }

    // IUnityPlayerLifecycleEvents implementation
    override fun onUnityPlayerUnloaded() {
        // Handle unload if necessary
    }

    override fun onUnityPlayerQuitted() {
        // Handle quit if necessary
    }

    // Inner class for View Factory
    inner class UnityViewFactory(private val activity: MainActivity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            return UnityView(context, activity)
        }
    }

    // Inner class for UnityView
    inner class UnityView(context: Context, private val activity: MainActivity) : PlatformView {
        private val frameLayout: FrameLayout = FrameLayout(context)

        init {
            if (unityPlayer == null) {
                 // Instantiate the specific concrete class
                 unityPlayer = UnityPlayerForActivityOrService(activity, activity)
            }
            
            // Cast explicitly to View to avoid 'Cannot access class D0' package-private error
            // We use (View) cast on the result of the property access if possible, or try to assign to View variable.
            val rawPlayer = unityPlayer as? UnityPlayerForActivityOrService
            // Use safe cast to View immediately to avoid inferring D0
            val view: View? = rawPlayer?.view as? View
            
            if (view != null) {
                val parent = view.parent as? android.view.ViewGroup
                parent?.removeView(view)
                frameLayout.addView(view)
                
                unityPlayer?.windowFocusChanged(true)
                view.requestFocus()
                unityPlayer?.resume()
            }
        }

        override fun getView(): View {
            return frameLayout
        }

        override fun dispose() {
             val rawPlayer = unityPlayer as? UnityPlayerForActivityOrService
             val view: View? = rawPlayer?.view as? View
             if (view != null) {
                 val parent = view.parent as? android.view.ViewGroup
                 parent?.removeView(view)
             }
        }
    }
}
