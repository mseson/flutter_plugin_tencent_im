package com.dm.push;

import android.content.Context;
import android.util.Log;

import com.vivo.push.model.UPSNotificationMessage;
import com.vivo.push.sdk.OpenClientPushMessageReceiver;


public class VIVOPushMessageReceiverImpl extends OpenClientPushMessageReceiver {
    private static final String TAG = "VIVOPushMessageReceiver";
    @Override
    public void onNotificationMessageClicked(Context context
            , UPSNotificationMessage upsNotificationMessage) {
        Log.i(TAG, "onNotificationMessageClicked");
    }

    @Override
    public void onReceiveRegId(Context context, String regId) {
        // vivo regId 有变化会走这个回调。根据官网文档，获取 regId
        // 需要在开启推送的回调里面调用PushClient.getInstance(getApplicationContext()).getRegId();
        // 参考 LoginActivity
        Log.i(TAG, "onReceiveRegId = " + regId);
    }
}
