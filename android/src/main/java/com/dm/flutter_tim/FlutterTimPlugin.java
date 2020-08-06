package com.dm.flutter_tim;

import android.util.Log;

import com.dm.push.ThirdPushTokenMgr;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
//import com.huawei.android.hms.agent.HMSAgent;
//import com.huawei.android.hms.agent.common.handler.ConnectHandler;
//import com.huawei.android.hms.agent.push.handler.GetTokenHandler;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfo;
import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConnListener;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMGroupEventListener;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMGroupTipsElem;
import com.tencent.imsdk.TIMImageElem;
import com.tencent.imsdk.TIMLogLevel;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMMessageListener;
import com.tencent.imsdk.TIMOfflinePushSettings;
import com.tencent.imsdk.TIMSdkConfig;
import com.tencent.imsdk.TIMTextElem;
import com.tencent.imsdk.TIMUserConfig;
import com.tencent.imsdk.TIMUserProfile;
import com.tencent.imsdk.TIMUserStatusListener;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfoResult;
import com.tencent.imsdk.ext.group.TIMGroupMemberResult;
import com.tencent.imsdk.ext.message.TIMManagerExt;
import com.tencent.imsdk.friendship.TIMDelFriendType;
import com.tencent.imsdk.friendship.TIMFriend;
import com.tencent.imsdk.friendship.TIMFriendRequest;
import com.tencent.imsdk.friendship.TIMFriendResponse;
import com.tencent.imsdk.friendship.TIMFriendResult;
import com.tencent.imsdk.session.SessionWrapper;
import com.tencent.imsdk.utils.IMFunc;
//import com.vivo.push.IPushActionListener;
//import com.vivo.push.PushClient;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;



import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/** FlutterTimPlugin */
public class FlutterTimPlugin implements MethodCallHandler {
  private static final String TAG = "TimPlugin";
  private Registrar registrar;
  private static EventChannel.EventSink eventMsgSink;
//  private static EventChannel.EventSink eventGroupTipsSink;
  private TIMMessageListener timMessageListener;
//  private TIMGroupEventListener timGroupEventListener;


  public FlutterTimPlugin(Registrar registrar) {
    this.registrar = registrar;
    //消息监听器
    timMessageListener = new TIMMessageListener() {
      @Override
      public boolean onNewMessages(List<TIMMessage> list) {

        if (list != null && list.size() > 0) {

          List<Message> messages = new ArrayList<>();
          for (TIMMessage timMessage : list) {
            messages.add(new Message(timMessage));
          }
          eventMsgSink.success(new Gson().toJson(messages, new TypeToken<Collection<Message>>() {
          }.getType()));
        }
        return false;
      }
    };
//    //群组事件监听器
//    timGroupEventListener = new TIMGroupEventListener() {
//      @Override
//      public void onGroupTipsEvent(TIMGroupTipsElem elem) {
//        Log.d(TAG,"onGroupTipsEvent"+new Gson().toJson(elem, new TypeToken<TIMGroupTipsElem>() {
//        }.getType()));
//        eventGroupTipsSink.success(new Gson().toJson(elem, new TypeToken<TIMGroupTipsElem>() {
//        }.getType()));
//      }
//    };
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "tim_method");

    final EventChannel eventMsgChannel = new EventChannel(registrar.messenger(), "tim_event_msg");

//    final EventChannel eventGroupChannel = new EventChannel(registrar.messenger(), "tim_event_group");


    final FlutterTimPlugin timPlugin = new FlutterTimPlugin(registrar);
    channel.setMethodCallHandler(timPlugin);

    eventMsgChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object o,final EventChannel.EventSink sink) {
        eventMsgSink = sink;
      }

      @Override
      public void onCancel(Object o) {
        Log.e(TAG, "onCancel() called with: o = [" + o + "]");
      }
    });

//    eventGroupChannel.setStreamHandler(new EventChannel.StreamHandler() {
//      @Override
//      public void onListen(Object o,final EventChannel.EventSink sink) {
//        eventGroupTipsSink = sink;
//      }
//
//      @Override
//      public void onCancel(Object o) {
//        Log.e(TAG, "onCancel() called with: o = [" + o + "]");
//
//      }
//    });

  }


  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }//登录并初始化im sdk
    else if (call.method.equals("imLogin")) {
      int appid = call.argument("sdkAppId");
      String identifier = call.argument("identifier");
      String userSig = call.argument("userSig");

      //判断是否是在主线程
      if (SessionWrapper.isMainProcess(registrar.context())) {
        //初始化 SDK 基本配置
        TIMSdkConfig config = new TIMSdkConfig(appid)
                .enableLogPrint(true)
                //日志级别
                .setLogLevel(TIMLogLevel.DEBUG);
                //日志路径
//                .setLogPath(Environment.getExternalStorageDirectory().getPath());
        //初始化 SDK
        TIMManager.getInstance().init(registrar.context(), config);


        //设置消息监听器，收到新消息时，通过此监听器回调
        TIMManager.getInstance().addMessageListener(timMessageListener);


        //基本用户配置
        TIMUserConfig userConfig = new TIMUserConfig()
                //设置用户状态变更事件监听器
                .setUserStatusListener(new TIMUserStatusListener() {
                  @Override
                  public void onForceOffline() {
                    //被其他终端踢下线
                    Log.i(TAG, "onForceOffline");
                  }

                  @Override
                  public void onUserSigExpired() {
                    //用户签名过期了，需要刷新 userSig 重新登录 SDK
                    Log.i(TAG, "onUserSigExpired");
                  }
                })
                //设置连接状态事件监听器
                .setConnectionListener(new TIMConnListener() {
                  @Override
                  public void onConnected() {
                    Log.i(TAG, "onConnected");
                  }

                  @Override
                  public void onDisconnected(int code, String desc) {
                    Log.i(TAG, "onDisconnected");
                  }

                  @Override
                  public void onWifiNeedAuth(String name) {
                    Log.i(TAG, "onWifiNeedAuth");
                  }
                });
//                //设置群组事件监听器
//                .setGroupEventListener(new TIMGroupEventListener() {
//                  @Override
//                  public void onGroupTipsEvent(TIMGroupTipsElem elem) {
//                    Log.i(TAG, "onGroupTipsEvent, type: " + elem.getTipsType());
//                  }
//                });

        userConfig.setReadReceiptEnabled(true);


        //设置会话刷新监听器
//        userConfig.setRefreshListener(timRefreshListener);
        //设置群组事件监听器
//        userConfig.setGroupEventListener(timGroupEventListener);
        //开启消息已读回执
        userConfig.enableReadReceipt(true);

        //将用户配置与通讯管理器进行绑定
        TIMManager.getInstance().setUserConfig(userConfig);


      }
      if (IMFunc.isBrandVivo()) {
        // vivo 离线推送
        PushClient.getInstance(registrar.context()).turnOnPush(new IPushActionListener() {
          @Override
          public void onStateChanged(int state) {
            if (state == 0) {
              String regId = PushClient.getInstance(registrar.context()).getRegId();
              Log.d(TAG, "vivopush open vivo push success regId = " + regId);
              ThirdPushTokenMgr.getInstance().setThirdPushToken(regId);
              ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
            } else {
              // 根据 vivo 推送文档说明，state = 101表示该 vivo 机型或者版本不支持 vivo 推送，详情请参考 vivo 推送常见问题汇总
              Log.d(TAG, "vivopush open vivo push fail state = " + state);
            }
          }
        });
      }
      if (IMFunc.isBrandHuawei()) {
        // 华为离线推送
        HMSAgent.connect(registrar.activity(), new ConnectHandler() {
          @Override
          public void onConnect(int rst) {
            Log.d(TAG, "huawei push HMS connect end:" + rst);
          }
        });
        HMSAgent.Push.getToken(new GetTokenHandler() {
          @Override
          public void onResult(int rtnCode) {
            Log.d("huaweipush", "get token: end" + rtnCode);
          }
        });
      }


      // identifier为用户名，userSig 为用户登录凭证
      TIMManager.getInstance().login(identifier, userSig, new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          Log.d(TAG, "login failed. code: " + code + " errmsg: " + desc);
          result.error(desc, String.valueOf(code), null);
        }

        @Override
        public void onSuccess() {

          ThirdPushTokenMgr.getInstance().setIsLogin(true);
          ThirdPushTokenMgr.getInstance().setPushTokenToTIM();

          //设置全局离线推送配置
          TIMOfflinePushSettings settings = new TIMOfflinePushSettings();
          //开启离线推送
          settings.setEnabled(true);
          //设置收到 C2C 离线消息时的提示声音
          settings.setC2cMsgRemindSound(null);
          //设置收到群离线消息时的提示声音
          settings.setGroupMsgRemindSound(null);
          TIMManager.getInstance().setOfflinePushSettings(settings);

          Log.d(TAG, "login succ");
          result.success("login succ");
        }
      });

    }//登录初始化结束
    //登出开始
    else if(call.method.equals("imLogout")){
      //登出
      TIMManager.getInstance().logout(new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {

          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          Log.d(TAG, "logout failed. code: " + code + " errmsg: " + desc);
          result.error("logout failed. code: " , code +" errmsg: ", desc);
        }

        @Override
        public void onSuccess() {
          //登出成功
          Log.d(TAG,"logout succ");
          result.success("logout succ");

        }
      });

    }//登出结束
    //获取当前登录用户开始
    else if(call.method.equals("getLoginUser")){
        String user = TIMManager.getInstance().getLoginUser();
        result.success(user);
    }
    //获取当前登录用户结束
    //已读消息上报开始 C2C
    else if(call.method.equals("setReadMessage")){
      String identifier = call.argument("identifier");

      TIMConversation conversation = TIMManager.getInstance().getConversation(
              TIMConversationType.C2C,    //会话类型：单聊
              identifier);                      //会话对方用户帐号
      //将此会话的所有消息标记为已读
      conversation.setReadMessage(null, new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {
          Log.e(TAG, "setReadMessage failed, code: " + code + "|desc: " + desc);
        }
        @Override
        public void onSuccess() {
          Log.d(TAG, "setReadMessage succ");
        }
      });
    }
    //已读消息上报结束
    //获取好友列表开始
    else if (call.method.equals("listFriends")) {
      //获取好友列表
      TIMFriendshipManager.getInstance().getFriendList(new TIMValueCallBack<List<TIMFriend>>() {
        @Override
        public void onError(int code, String desc) {
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          result.error(desc, String.valueOf(code), null);
        }

        @Override
        public void onSuccess(List<TIMFriend> timFriends) {
          if (timFriends != null && timFriends.size() > 0) {

            result.success(new Gson().toJson(timFriends, new TypeToken<Collection<TIMFriend>>() {
            }.getType()));
          } else {
            result.success("[]");//返回一个空的json array
          }
        }
      });
    }//获取好友列表结束
    //获取用户信息开始
    else if(call.method.equals("getUsersProfile")){
      //待获取用户资料的用户列表
      List<String> users = new ArrayList<String>();
      String identifier = call.argument("identifier");
      users.add(identifier);
      //获取用户资料
      TIMFriendshipManager.getInstance().getUsersProfile(users, true, new TIMValueCallBack<List<TIMUserProfile>>(){
        @Override
        public void onError(int code, String desc){
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          Log.e(TAG, "getUsersProfile failed: " + code + " desc");
        }

        @Override
        public void onSuccess(List<TIMUserProfile> result){
          Log.e(TAG, "getUsersProfile succ");
          for(TIMUserProfile res : result){
            Log.e(TAG, "identifier: " + res.getIdentifier() + " nickName: " + res.getNickName()
                    + " faceUrl: " + res.getFaceUrl());
          }
        }
      });
    }
    //获取用户信息结束
    //添加好友开始
    else if (call.method.equals("addFriend")) {
      //添加好友请求
      String identifier = call.argument("identifier");
      TIMFriendRequest req = new TIMFriendRequest(identifier);
      req.setAddWording("请添加我...");
      //申请添加好友
      TIMFriendshipManager.getInstance().addFriend(req, new TIMValueCallBack<TIMFriendResult>() {
        @Override
        public void onError(int i, String s) {
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          result.error(s, String.valueOf(i), null);
        }

        @Override
        public void onSuccess(TIMFriendResult timFriendResult) {
          result.success(timFriendResult.getIdentifier());
        }
      });
    }//申请添加好友结束
    //处理好友申请开始
    else if (call.method.equals("opFriend")) {//好友申请
      //获取好友列表
      String identifier = call.argument("identifier");
      String opTypeStr = call.argument("opTypeStr");
      TIMFriendResponse timFriendResponse = new TIMFriendResponse();
      timFriendResponse.setIdentifier(identifier);
      if (opTypeStr.toUpperCase().trim().equals("Y")) {//同意添加
        timFriendResponse.setResponseType(TIMFriendResponse.TIM_FRIEND_RESPONSE_AGREE);
      } else {//拒绝添加
        timFriendResponse.setResponseType(TIMFriendResponse.TIM_FRIEND_RESPONSE_REJECT);
      }
      TIMFriendshipManager.getInstance().doResponse(timFriendResponse, new TIMValueCallBack<TIMFriendResult>() {
        @Override
        public void onError(int i, String s) {
          result.error(s, String.valueOf(i), null);
        }

        @Override
        public void onSuccess(TIMFriendResult timFriendResult) {
          result.success(timFriendResult.getIdentifier());
        }
      });
    }
    //处理好友申请结束
    //删除好友开始
    else if (call.method.equals("delFriend")) {
      String identifier = call.argument("identifier");
      List<String> list = new ArrayList<>();
      list.add(identifier);
      //双向删除好友
      TIMFriendshipManager.getInstance().deleteFriends(list, TIMDelFriendType.TIM_FRIEND_DEL_BOTH, new TIMValueCallBack<List<TIMFriendResult>>() {
        @Override
        public void onError(int i, String s) {//错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          result.error(s, String.valueOf(i), null);
        }

        @Override
        public void onSuccess(List<TIMFriendResult> timFriendResults) {
          result.success(timFriendResults.get(0).getIdentifier());
        }
      });

    }
    //删除好友结束
    //获取会话列表开始
    else if (call.method.equals("getConversationList")) {
      List<TIMConversation> list = TIMManager.getInstance().getConversationList();
      if (list != null && list.size() > 0) {
        List<Conversation> conversations = new ArrayList<>();
        for (TIMConversation rcd:list){
          conversations.add(new Conversation(rcd));
        }
        result.success(new Gson().toJson(conversations, new TypeToken<Collection<TIMConversation>>() {
        }.getType()));
      } else {
        result.success("[]");
      }
    }//获取会话列表结束
    //获取未读消息数开始
//    else if(call.method.equals("getUnreadMessageNum")){
//      String identifier = call.argument("identifier");
//      //获取会话扩展实例
//      TIMConversation con = TIMManager.getInstance().getConversation(TIMConversationType.C2C, identifier);
////      TIMConversationExt conExt = new TIMConversationExt(con);
//      //获取会话未读数
//      long num = con.getUnreadMessageNum();
//      Log.d(TAG, "unread msg num: " + num);
//      result.success(num);
//    }//获取未读消息数结束
    //删除会话开始
    else if (call.method.equals("deleteConversation")) {
      String identifier = call.argument("identifier");
      TIMManagerExt.getInstance().deleteConversation(TIMConversationType.C2C, identifier);
      result.success("delConversation success");
    }//删除会话结束
    //获取漫游消息开始
    else if (call.method.equals("getMessages")) {
      String identifier = call.argument("identifier");
      //获取会话扩展实例
      TIMConversation con = TIMManager.getInstance().getConversation(TIMConversationType.C2C, identifier);
//      TIMConversationExt conExt = new TIMConversationExt(con);
//      TIMMessage lastMsg = con.getLastMsg();

      //获取此会话的消息
      con.getMessage(20, //获取此会话最近的 20 条消息
              null, //不指定从哪条消息开始获取 - 等同于从最新的消息开始往前
              new TIMValueCallBack<List<TIMMessage>>() {//回调接口
                @Override
                public void onError(int code, String desc) {//获取消息失败
                  //接口返回了错误码 code 和错误描述 desc，可用于定位请求失败原因
                  //错误码 code 含义请参见错误码表
                  Log.d(TAG, "get message failed. code: " + code + " errmsg: " + desc);
                }
                @Override
                public void onSuccess(List<TIMMessage> msgs) {//获取消息成功
                  //遍历取得的消息
                  if (msgs != null && msgs.size() > 0) {
                    List<Message> messages = new ArrayList<>();
                    for (TIMMessage timMessage : msgs) {
                      messages.add(new Message(timMessage));
                    }
                    result.success(new Gson().toJson(messages, new TypeToken<Collection<Message>>() {
                    }.getType()));
                  } else {
                    result.success("[]");
                  }
                }
              });
    } //获取漫游消息结束
    // 获取本地消息开始
    else if (call.method.equals("getLocalMessages")) {
      String identifier = call.argument("identifier");

      //初始化本地存储
      TIMManager.getInstance().initStorage(identifier, new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {
          Log.d(TAG, "initStorage failed, code: " + code + "|descr: " + desc);
        }

        @Override
        public void onSuccess() {
          Log.d(TAG, "initStorage succ");
        }
      });

      //获取会话扩展实例
      TIMConversation con = TIMManager.getInstance().getConversation(TIMConversationType.C2C, identifier);
//      TIMConversationExt conExt = new TIMConversationExt(con);

      //获取此会话的消息
      con.getLocalMessage(20, //获取此会话最近的 20 条消息
              null, //不指定从哪条消息开始获取 - 等同于从最新的消息开始往前
              new TIMValueCallBack<List<TIMMessage>>() {//回调接口
                @Override
                public void onError(int code, String desc) {//获取消息失败
                  //接口返回了错误码 code 和错误描述 desc，可用于定位请求失败原因
                  //错误码 code 含义请参见错误码表
                  Log.d(TAG, "get message failed. code: " + code + " errmsg: " + desc);
                }
                @Override
                public void onSuccess(List<TIMMessage> msgs) {//获取消息成功
                  //遍历取得的消息
                  if (msgs != null && msgs.size() > 0) {
                    List<Message> messages = new ArrayList<>();
                    for (TIMMessage timMessage : msgs) {
                      messages.add(new Message(timMessage));
                    }
                    result.success(new Gson().toJson(messages, new TypeToken<Collection<Message>>() {
                    }.getType()));
                  } else {
                    result.success("[]");
                  }
                }
              });
    } //获取本地消息结束
    //发送文本消息开始
    else if (call.method.equals("sendTextMessages")) {
      String identifier = call.argument("identifier");
      int conversationType = call.argument("conversationType");
      String content = call.argument("content");
      TIMMessage msg = new TIMMessage();

      //添加文本内容
      TIMTextElem elem = new TIMTextElem();
      elem.setText(content);

      //将elem添加到消息
      if (msg.addElement(elem) != 0) {
        Log.d(TAG, "addElement failed");
        return;
      }
      TIMConversation conversation = null;
      if(1 == conversationType){
        conversation = TIMManager.getInstance().getConversation(TIMConversationType.C2C, identifier);
      }else {
        conversation = TIMManager.getInstance().getConversation(TIMConversationType.Group, identifier);
      }
      //发送消息
      conversation.sendMessage(msg, new TIMValueCallBack<TIMMessage>() {//发送消息回调
        @Override
        public void onError(int code, String desc) {//发送消息失败
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
//          Log.d(TAG, "send message failed. code: " + code + " errmsg: " + desc);
//          result.error("send message failed. code: ", desc, code);
          result.success("{\"success\":0,\"code\":"+code+"}");
        }

        @Override
        public void onSuccess(TIMMessage msg) {//发送消息成功
//          Log.e(TAG, "SendMsg ok");

          String json = new Gson().toJson(new Message(msg), new TypeToken<Message>() {
          }.getType());
          result.success("{\"success\":1,\"data\":"+json+"}");
//          result.success(new Gson().toJson(new Message(msg), new TypeToken<Message>() {
//          }.getType()));
        }
      });
    }
    //发送文本消息结束
    //发送图片消息开始
    else if (call.method.equals("sendImageMessages")) {
      String identifier = call.argument("identifier");
      int conversationType = call.argument("conversationType");
      String iamgePath = call.argument("imagePath");
      //构造一条消息
      TIMMessage msg = new TIMMessage();

      //添加图片
      TIMImageElem elem = new TIMImageElem();
      Log.d(TAG, "后台收到的图片地址："+iamgePath);
//      elem.setPath(Environment.getExternalStorageDirectory() + iamgePath);
      elem.setPath(iamgePath);
      //将 elem 添加到消息

      if (msg.addElement(elem) != 0) {
        Log.d(TAG, "addElement failed");
        return;
      }
      TIMConversation conversation = null;
      if(1 == conversationType){
        conversation = TIMManager.getInstance().getConversation(TIMConversationType.C2C, identifier);
      }else {
        conversation = TIMManager.getInstance().getConversation(TIMConversationType.Group, identifier);
      }      //发送消息
      conversation.sendMessage(msg, new TIMValueCallBack<TIMMessage>() {//发送消息回调
        @Override
        public void onError(int code, String desc) {//发送消息失败
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          Log.d(TAG, "send message failed. code: " + code + " errmsg: " + desc);
//          result.error("send message failed. code: ", desc, code);
          result.success("{\"success\":0,\"code\":"+code+"}");

        }

        @Override
        public void onSuccess(TIMMessage msg) {//发送消息成功
          Log.e(TAG, "SendImgMsg ok");
//          result.success(new Gson().toJson(new Message(msg), new TypeToken<Message>() {
//          }.getType()));

          String json = new Gson().toJson(new Message(msg), new TypeToken<Message>() {
          }.getType());
          result.success("{\"success\":1,\"data\":"+json+"}");
        }
      });
    }
    //发送图片消息结束
    // 发送文件
    else if (call.method.equals("sendFileMessages")){
      //构造一条消息
//          TIMMessage msg = new TIMMessage();
//
//    //添加文件内容
//          TIMFileElem elem = new TIMFileElem();
//          elem.setPath('/'); //设置文件路径
//          elem.setFileName("myfile.bin"); //设置消息展示用的文件名称
//
//    //将 elem 添加到消息
//          if(msg.addElement(elem) != 0) {
//            Log.d(tag, "addElement failed");
//            return;
//          }
//    //发送消息
//          conversation.sendMessage(msg, new TIMValueCallBack<TIMMessage>() {//发送消息回调
//            @Override
//            public void onError(int code, String desc) {//发送消息失败
//              //错误码 code 和错误描述 desc，可用于定位请求失败原因
//              //错误码 code 含义请参见错误码表
//              Log.d(tag, "send message failed. code: " + code + " errmsg: " + desc);
//            }
//
//            @Override
//            public void onSuccess(TIMMessage msg) {//发送消息成功
//              Log.e(tag, "SendMsg ok");
//            }
//          });
    }//创建群聊
    else if(call.method.equals("createGroup")){
      String identifiers = call.argument("identifiers");
      String groupName = call.argument("groupName");

      //创建私有群
      TIMGroupManager.CreateGroupParam param = new TIMGroupManager.CreateGroupParam("Private", groupName);

      //添加群成员
      List<TIMGroupMemberInfo> infos = new ArrayList<TIMGroupMemberInfo>();
      String arr[] = identifiers.split(",");
      for (String identifier: arr) {
        TIMGroupMemberInfo member = new TIMGroupMemberInfo(identifier);
        infos.add(member);
      }
      param.setMembers(infos);
      //创建群组
      TIMGroupManager.getInstance().createGroup(param, new TIMValueCallBack<String>() {
        @Override
        public void onError(int code, String desc) {
          result.success("{\"success\":0,\"code\":"+code+" msg:\"" + desc+"\"}");
          Log.d(TAG, "create group failed. code: " + code + " errmsg: " + desc);
        }

        @Override
        public void onSuccess(String s) {
          result.success("{\"success\":1,\"groupId\":\""+s+"\"}");

          Log.d(TAG, "create group succ, groupId:" + s);
        }
      });
    }//邀请用户进入群聊
    else if(call.method.equals("inviteGroupMember")){
      String identifiers = call.argument("identifiers");
      String groupId = call.argument("groupId");

      //添加群成员
      List memberList = new ArrayList();
      String arr[] = identifiers.split(",");
      for (String identifier: arr) {
        memberList.add(identifier);
      }
      //回调
      TIMValueCallBack<List<TIMGroupMemberResult>> cb = new TIMValueCallBack<List<TIMGroupMemberResult>>() {
        @Override
        public void onError(int code, String desc) {
          result.success("{\"success\":0,\"code\":"+code+" errmsg: " + desc+"}");
        }

        @Override
        public void onSuccess(List<TIMGroupMemberResult> results) { //群组成员操作结果
          for(TIMGroupMemberResult r : results) {
            Log.d(TAG, "result: " + r.getResult()  //操作结果:  0:添加失败；1：添加成功；2：原本是群成员
                    + " user: " + r.getUser());    //用户帐号
          }
          result.success("{\"success\":1}");
        }
      };

      //将 list 中的用户加入群组
      TIMGroupManager.getInstance().inviteGroupMember(
              groupId,   //群组 ID
              memberList,      //待加入群组的用户列表
              cb);
    }//退出群聊
    else if(call.method.equals("quitGroup")){
      String groupId = call.argument("groupId");

      //创建回调
      TIMCallBack cb = new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 含义请参见错误码表
          result.success("{\"success\":0,\"code\":"+code+" msg:\"" + desc+"\"}");

        }

        @Override
        public void onSuccess() {
          result.success("{\"success\":1}");

          Log.e(TAG, "quit group succ");
        }
      };

      //退出群组
      TIMGroupManager.getInstance().quitGroup(
              groupId,  //群组 ID
              cb);
    }
    //修改群名
    else if(call.method.equals("modifyGroupName")){
      String groupId = call.argument("groupId");
      //群名
      String groupName = call.argument("groupName");

      TIMGroupManager.ModifyGroupInfoParam param = new TIMGroupManager.ModifyGroupInfoParam(groupId);
      param.setGroupName(groupName);

      TIMGroupManager.getInstance().modifyGroupInfo(param, new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {
          result.success("{\"success\":0,\"code\":"+code+" msg:\"" + desc+"\"}");
          Log.e(TAG, "modify group info failed, code:" + code +"|desc:" + desc);
        }

        @Override
        public void onSuccess() {
          result.success("{\"success\":1}");
          Log.e(TAG, "modify group info succ");
        }
      });

    }//修改群公告
    else if(call.method.equals("modifyGroupNotification")){
      String groupId = call.argument("groupId");
      //群公告
      String notification = call.argument("notification");
      TIMGroupManager.ModifyGroupInfoParam param = new TIMGroupManager.ModifyGroupInfoParam(groupId);
      param.setNotification(notification);
      TIMGroupManager.getInstance().modifyGroupInfo(param, new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {
          result.success("{\"success\":0,\"code\":"+code+" msg:\"" + desc+"\"}");
          Log.e(TAG, "modify group info failed, code:" + code +"|desc:" + desc);
        }
        @Override
        public void onSuccess() {
          result.success("{\"success\":1}");
          Log.e(TAG, "modify group info succ");
        }
      });

    }//修改头像
    else if(call.method.equals("modifyGroupFaceUrl")){
      String groupId = call.argument("groupId");
      //群头像
      String faceUrl = call.argument("faceUrl");
      TIMGroupManager.ModifyGroupInfoParam param = new TIMGroupManager.ModifyGroupInfoParam(groupId);
      param.setFaceUrl(faceUrl);
      TIMGroupManager.getInstance().modifyGroupInfo(param, new TIMCallBack() {
        @Override
        public void onError(int code, String desc) {
          result.success("{\"success\":0,\"code\":"+code+" msg:\"" + desc+"\"}");
          Log.e(TAG, "modify group info failed, code:" + code +"|desc:" + desc);
        }
        @Override
        public void onSuccess() {
          result.success("{\"success\":1}");
          Log.e(TAG, "modify group info succ");
        }
      });
    }
    //获取群组成员
    else if(call.method.equals("getGroupMembers")){
      String groupId = call.argument("groupId");

      //创建回调
      TIMValueCallBack<List<TIMGroupMemberInfo>> cb = new TIMValueCallBack<List<TIMGroupMemberInfo>> () {
        @Override
        public void onError(int code, String desc) {
          Log.e(TAG, "get groupMembers info failed, code:" + code +"|desc:" + desc);
          result.success("{\"success\":0,\"code\":"+code+" msg:\"" + desc+"\"}");
        }

        @Override
        public void onSuccess(List<TIMGroupMemberInfo> infoList) {//参数返回群组成员信息

          String json = new Gson().toJson(infoList, new TypeToken<Collection<TIMGroupMemberInfo>>() {
          }.getType());
          result.success("{\"success\":1,\"data\":"+json+"}");
        }
      };
      //获取群组成员信息
      TIMGroupManager.getInstance().getGroupMembers(
              groupId, //群组 ID
              cb);
    }//获取群组资料
    else if(call.method.equals("getGroupInfo")){
      String groupId = call.argument("groupId");

      //创建待获取信息的群组 ID 列表
      ArrayList<String> groupList = new ArrayList<String>();

      //创建回调
      TIMValueCallBack<List<TIMGroupDetailInfoResult>> cb = new TIMValueCallBack<List<TIMGroupDetailInfoResult>>() {
        @Override
        public void onError(int code, String desc) {
          //错误码 code 和错误描述 desc，可用于定位请求失败原因
          //错误码 code 列表请参见错误码表
          Log.e(TAG, "get group info failed, code:" + code +"|desc:" + desc);
          result.success("{\"success\":0,\"code\":"+code+" msg:\"" + desc+"\"}");
        }

        @Override
        public void onSuccess(List<TIMGroupDetailInfoResult> infoList) { //参数中返回群组信息列表
          String json = new Gson().toJson(infoList, new TypeToken<Collection<TIMGroupDetailInfoResult>>() {
          }.getType());
          result.success("{\"success\":1,\"data\":"+json+"}");
        }
      };

      //添加群组 ID
      groupList.add(groupId);

      //获取服务器群组信息
      TIMGroupManager.getInstance().getGroupInfo(groupList,cb);
//      TIMGroupManager.getInstance().getGroupInfo(
//              groupList, //需要获取信息的群组 ID 列表
//              cb);
    }
    else {
      result.notImplemented();
    }
  }



  class Message {
    String identifier;
    int conversationType;
    TIMElem message;
    int isSelf;
    int isRead;
    long sendTime;
    int type;
    String sender;
    String groupName;

    Message(TIMMessage timMessage) {
      conversationType = timMessage.getConversation().getType().value();
      identifier = timMessage.getConversation().getPeer();
      sendTime = timMessage.timestamp();
      message = timMessage.getElement(0);
      isSelf = timMessage.isSelf()?1:0;
      isRead = timMessage.isRead()?1:0;
      type = message.getType().value();
      sender = timMessage.getSender();
      if(timMessage.getConversation().getType().value() ==2){
        //获取本地缓存的群组信息
        groupName = timMessage.getConversation().getGroupName();
      }


    }
  }
  class Conversation{
    String identifier;
    int conversationType;
    String msg;
    long unReadNum;
    long sendTime;

    Conversation(TIMConversation timConversation){
      TIMMessage lastMsg = timConversation.getLastMsg();
      conversationType = timConversation.getType().value();
      identifier = timConversation.getPeer();
      sendTime = lastMsg.timestamp();
      TIMElem message = lastMsg.getElement(0);
      if(message.getType().value()==1){
        TIMTextElem textElem = (TIMTextElem)message;
        msg = textElem.getText();
      }else if(message.getType().value() == 4){
        msg = "[图片]";
      }else if(message.getType().value() == 5){
        msg = "[语言]";
      }else if(message.getType().value() == 15){
        msg = "[视频]";
      }else if(message.getType().value() == 7){
        msg = "[文件]";
      }
      unReadNum = timConversation.getUnreadMessageNum();
    }
  }
}
