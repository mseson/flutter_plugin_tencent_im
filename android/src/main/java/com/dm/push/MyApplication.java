package com.dm.push;


import android.util.Log;

import com.dm.flutter_tim.R;
import com.huawei.android.hms.agent.HMSAgent;
import com.meizu.cloud.pushsdk.PushManager;
import com.meizu.cloud.pushsdk.util.MzSystemUtils;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMOfflinePushListener;
import com.tencent.imsdk.TIMOfflinePushNotification;
import com.tencent.imsdk.session.SessionWrapper;
import com.tencent.imsdk.utils.IMFunc;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;



import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication{

    @Override
    public void onCreate() {
        super.onCreate();
        //判断是否是在主线程
        if (SessionWrapper.isMainProcess(getApplicationContext())) {
            // 设置离线推送监听器
            TIMManager.getInstance().setOfflinePushListener(new TIMOfflinePushListener() {

                @Override
                public void handleNotification(TIMOfflinePushNotification notification) {
                    Log.d("MyApplication", "recv offline push");

                    // 这里的 doNotify 是 IM SDK 内置的通知栏提醒，应用也可以选择自己利用回调参数 notification 来构造自己的通知栏提醒
                     notification.doNotify(getApplicationContext(), R.drawable.c_buoycircle_icon);
                }
            });

            //华为
            if(IMFunc.isBrandHuawei()){
                // 华为离线推送
               HMSAgent.init(this);
            }
            //小米离线推送
            if(IMFunc.isBrandXiaoMi()){
                MiPushClient.registerPush(this, Constants.XM_PUSH_APPID, Constants.XM_PUSH_APPKEY);

            }
            //VIVO
            if(IMFunc.isBrandVivo()){
                // vivo 离线推送
                PushClient.getInstance(getApplicationContext()).initialize();
            }

            // 魅族
            if(MzSystemUtils.isBrandMeizu(this)){
                // 魅族离线推送
                PushManager.register(this, Constants.MZ_PUSH_APPID, Constants.MZ_PUSH_APPKEY);
            }
        }


    }


    }
