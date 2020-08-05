package com.dm.push;

import android.os.Bundle;
import android.util.Log;
import android.content.Context;

import com.huawei.hms.support.api.push.PushReceiver;


public class HUAWEIPushReceiver extends PushReceiver {
    private static final String TAG = "HUAWEIPushReceiver";
    @Override
    public boolean onPushMsg(Context context, byte[] msgBytes, Bundle extras) {
        try {
            // CP 可以自己解析消息内容，然后做相应的处理
            String content = new String(msgBytes, "UTF-8");
            Log.d(TAG, "收到PUSH透传消息,消息内容为:" + content);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public void onToken(Context context, String token, Bundle extras) {
        Log.d(TAG, "onToken:" + token);
        System.out.print(".....onToken:"+token);
        ThirdPushTokenMgr.getInstance().setThirdPushToken(token);  // token 在此处传入，后续推送信息上报时需要使用
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
    }
}
