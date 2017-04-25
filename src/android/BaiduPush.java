package com.cordova.plugins.push.by.du;

import android.content.Context;

import com.baidu.android.pushservice.PushConstants;
import com.baidu.android.pushservice.PushManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * 百度云推送插件
 * 
 * @author NCIT
 *
 */
public class BaiduPush extends CordovaPlugin {
    /** LOG TAG */
    private static final String LOG_TAG = BaiduPush.class.getSimpleName();

    /** JS回调接口对象 */
    public static CallbackContext pushCallbackContext = null;
    public static CallbackContext onMessageCallbackContext = null;
    public static CallbackContext onNotificationClickedCallbackContext = null;
    public static CallbackContext onNotificationArrivedCallbackContext = null;

    /**
     * Gets the application context from cordova's main activity.
     * @return the application context
     */
    private Context getApplicationContext() {
        return this.cordova.getActivity().getApplicationContext();
    }


    public static void sendEvent(JSONObject _json) {
        sendEvent(onMessageCallbackContext,_json);
    }

    public static void sendError(String message) {
        sendError(onMessageCallbackContext,message);
    }

    public static void sendEvent(CallbackContext pushCallbackContext, JSONObject _json) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, _json);
        pluginResult.setKeepCallback(true);
        if (pushCallbackContext != null) {
            pushCallbackContext.sendPluginResult(pluginResult);
        }
    }

    public static void sendError(CallbackContext pushCallbackContext,String message) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, message);
        pluginResult.setKeepCallback(true);
        if (pushCallbackContext != null) {
            pushCallbackContext.sendPluginResult(pluginResult);
        }
    }


    /*
 * Sends the pushbundle extras to the client application.
 * If the client application isn't currently active, it is cached for later processing.
 */
//    public static void sendExtras(Bundle extras) {
//        if (extras != null) {
//            if (gWebView != null) {
//                sendEvent(convertBundleToJson(extras));
//            } else {
//                Log.v(LOG_TAG, "sendExtras: caching extras to send at a later time.");
//                gCachedExtras.add(extras);
//            }
//        }
//    }

    /**
     * 插件初始化
     */
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        LOG.d(LOG_TAG, "BaiduPush#initialize");

        super.initialize(cordova, webView);
    }

    /**
     * 插件主入口
     */
    @Override
    public boolean execute(String action, final JSONArray args, CallbackContext callbackContext) throws JSONException {
        LOG.d(LOG_TAG, "BaiduPush#execute");

        boolean ret = false;
        
        if ("init".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            
            final String apiKey = args.getString(0);
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    LOG.d(LOG_TAG, "PushManager#startWork");
                    PushManager.startWork(cordova.getActivity().getApplicationContext(),
                            PushConstants.LOGIN_TYPE_API_KEY, apiKey);
                }
            });
            ret =  true;
        } else if ("stopWork".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    LOG.d(LOG_TAG, "PushManager#stopWork");
                    PushManager.stopWork(cordova.getActivity().getApplicationContext());
                }
            });
            ret =  true;
        } else if ("resumeWork".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    LOG.d(LOG_TAG, "PushManager#resumeWork");
                    PushManager.resumeWork(cordova.getActivity().getApplicationContext());
                }
            });
            ret = true;
        } else if ("setTags".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    LOG.d(LOG_TAG, "PushManager#setTags");
                    
                    List<String> tags = null;
                    if (args != null && args.length() > 0) {
                        int len = args.length();
                        tags = new ArrayList<String>(len);
                        
                        for (int inx = 0; inx < len; inx++) {
                            try {
                                tags.add(args.getString(inx));
                            } catch (JSONException e) {
                                LOG.e(LOG_TAG, e.getMessage(), e);
                            }
                        }

                        PushManager.setTags(cordova.getActivity().getApplicationContext(), tags);
                    }
                    
                }
            });
            ret = true;
        } else if ("delTags".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    LOG.d(LOG_TAG, "PushManager#delTags");
                    
                    List<String> tags = null;
                    if (args != null && args.length() > 0) {
                        int len = args.length();
                        tags = new ArrayList<String>(len);
                        
                        for (int inx = 0; inx < len; inx++) {
                            try {
                                tags.add(args.getString(inx));
                            } catch (JSONException e) {
                                LOG.e(LOG_TAG, e.getMessage(), e);
                            }
                        }

                        PushManager.delTags(cordova.getActivity().getApplicationContext(), tags);
                    }
                    
                }
            });
            ret = true;
        } else if ("onMessage".equalsIgnoreCase(action)) {
            onMessageCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            ret = true;
        } else if ("onNotificationClicked".equalsIgnoreCase(action)) {
            onNotificationClickedCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            ret = true;
        } else if ("onNotificationArrived".equalsIgnoreCase(action)) {
            onNotificationArrivedCallbackContext = callbackContext;
            
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            ret = true;
        }

        return ret;
    }
}
