package com.dm.push;

import android.content.Context;
import android.util.Log;

import com.xiaomi.mipush.sdk.ErrorCode;
import com.xiaomi.mipush.sdk.MiPushClient;
import com.xiaomi.mipush.sdk.MiPushCommandMessage;
import com.xiaomi.mipush.sdk.MiPushMessage;
import com.xiaomi.mipush.sdk.PushMessageReceiver;

import java.util.List;

public class XiaomiMsgReceiver extends PushMessageReceiver {
    private static final String TAG = "XiaomiMsgReceiver";
    private String mRegId;

    // onReceivePassThroughMessage 用来接收服务器发送的透传消息，当前云通信 IM 暂不支持透传消息
    // @Override
    // public void onReceivePassThroughMessage(Context context, MiPushMessage miPushMessage) {
    //     Log.d(TAG, "onReceivePassThroughMessage is called. ");
    // }

    @Override
    public void onNotificationMessageClicked(Context context, MiPushMessage miPushMessage) {
        Log.d(TAG, "onNotificationMessageClicked is called. ");
    }

    @Override
    public void onNotificationMessageArrived(Context context, MiPushMessage miPushMessage) {
        Log.d(TAG, "onNotificationMessageArrived is called. ");
    }

    @Override
    public void onReceiveRegisterResult(Context context, MiPushCommandMessage miPushCommandMessage) {
        Log.d(TAG, "onReceiveRegisterResult is called. " + miPushCommandMessage.toString());
        String command = miPushCommandMessage.getCommand();
        List<String> arguments = miPushCommandMessage.getCommandArguments();
        String cmdArg1 = ((arguments != null && arguments.size() > 0) ? arguments.get(0) : null);

        Log.d(TAG, "cmd: " + command + " | arg: " + cmdArg1
                + " | result: " + miPushCommandMessage.getResultCode() + " | reason: " + miPushCommandMessage.getReason());

        if (MiPushClient.COMMAND_REGISTER.equals(command)) {
            if (miPushCommandMessage.getResultCode() == ErrorCode.SUCCESS) {
                mRegId = cmdArg1;
            }
        }

        Log.d(TAG, "regId: " + mRegId);
        System.out.println("XiaomiMsgReceiver regId:"+mRegId);
        ThirdPushTokenMgr.getInstance().setThirdPushToken(mRegId); // regId 在此处传入，后续推送信息上报时需要使用
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
    }

    @Override
    public void onCommandResult(Context context, MiPushCommandMessage miPushCommandMessage) {
        super.onCommandResult(context, miPushCommandMessage);
    }
}
