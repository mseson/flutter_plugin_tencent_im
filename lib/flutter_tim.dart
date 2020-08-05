import 'dart:async';

import 'package:flutter/services.dart';

class FlutterTim {
  static FlutterTim _instance;

  final MethodChannel _methodChannel;

  final EventChannel _eventMsgChannel;

  final EventChannel _eventGroupChannel;

  factory FlutterTim(){
    if(_instance == null){
      final MethodChannel methodChannel = const MethodChannel("tim_method");
      final EventChannel eventMsgChannel = const EventChannel("tim_event_msg");
      final EventChannel eventGroupChannel = const EventChannel("tim_event_group");

      _instance = new FlutterTim.private(methodChannel, eventMsgChannel,eventGroupChannel);
    }
    return _instance;
  }

  FlutterTim.private(this._methodChannel,this._eventMsgChannel,this._eventGroupChannel);

  Future<String> get platformVersion async {
    final String version = await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  Stream<dynamic> _msgListener;

//  Stream<dynamic> _conversationListener;

  Stream<dynamic> get onMessage {
    if (_msgListener == null) {
      _msgListener = _eventMsgChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parseBatteryState(event));
    }
    return _msgListener;
  }
//  Stream<dynamic> get onConversation {
//    if (_conversationListener == null) {
//      _conversationListener = _eventGroupChannel
//          .receiveBroadcastStream()
//          .map((dynamic event) => _parseBatteryState(event));
//    }
//    return _conversationListener;
//  }

  dynamic _parseBatteryState(event) {
    return event;
  }

  ///im登录
  Future<dynamic> imLogin(int appId, String identifier, String sig) async {
    return await _methodChannel.invokeMethod("imLogin", <String, dynamic>{
      'sdkAppId': appId,
      'identifier': identifier,
      'userSig': sig,

    });
  }

  ///im登出
  Future<dynamic> sdkLogout() async {
    return await _methodChannel.invokeMethod('imLogout');
  }
  ///获取当前登录用户
  Future<dynamic> getLoginUser() async {
    return await _methodChannel.invokeMethod('getLoginUser');
  }
  ///已读消息上报 C2C
  Future<dynamic> setReadMessage(String identifier) async{
    return await _methodChannel.invokeListMethod('setReadMessage',<String, dynamic>{
      'identifier':identifier});
  }
  ///获取离线消息
  Future<dynamic> getLocalMessages(String identifier) async {
    return await _methodChannel.invokeMethod('getLocalMessages',<String, dynamic>{
      'identifier':identifier
    });
  }

  ///获取好友列表
  Future<dynamic> listFriends(String identifier) async {
    return await _methodChannel.invokeMethod(
        "listFriends", <String, dynamic>{'identifier': identifier});
  }
  //获取用户资料
  Future<dynamic> getUsersProfile (String identifier) async{
    return await _methodChannel.invokeMethod("getUsersProfile",<String, dynamic>{'identifier': identifier});
  }
  ///添加好友
  Future<dynamic> addFriend(String identifier) async {
    return await _methodChannel
        .invokeMethod("addFriend", <String, dynamic>{'identifier': identifier});
  }
  ///处理好友的请求，接受/拒绝
  ///opTypeStr 接受传 Y
  ///opTypeStr 拒绝传 N
  Future<dynamic> opFriend(String identifier, String opTypeStr) async {
    return await _methodChannel.invokeMethod("opFriend",
        <String, dynamic>{'identifier': identifier, 'opTypeStr': opTypeStr});
  }

  ///删除好友
  Future<dynamic> delFriend(String identifier) async {
    return await _methodChannel
        .invokeMethod("delFriend", <String, dynamic>{'identifier': identifier});
  }

  ///获取会话列表
  Future<dynamic> getConversationList() async {
    return await _methodChannel.invokeMethod('getConversationList');
  }

  //获取会话未读消息
//  Future<dynamic> getUnreadMessageNum(String identifier) async{
//    return await _methodChannel.invokeMethod("getUnreadMessageNum",<String, dynamic>{'identifier': identifier});
//  }

  ///删除会话
  Future<dynamic> delConversation(String identifier) async {
    return await _methodChannel.invokeMethod(
        'delConversation', <String, String>{'identifier': identifier});
  }

  ///获取一个会话的消息
  Future<dynamic> getMessages(String identifier) async {
    return await _methodChannel.invokeMethod('getMessages',
        <String, dynamic>{'identifier': identifier});
  }

  ///发送文本消息
  Future<dynamic> sendTextMessages(String identifier,int conversationType, String content) async {
    return await _methodChannel.invokeMethod('sendTextMessages',
        <String, dynamic>{'identifier': identifier,'conversationType':conversationType, 'content': content});
  }

  ///发送图片消息
  Future<dynamic> sendImageMessages(String identifier,int conversationType, String imagePath) async {
    return await _methodChannel.invokeMethod('sendImageMessages',
        <String, dynamic>{'identifier': identifier, 'conversationType':conversationType,'imagePath': imagePath});
  }
  ///创建群聊
  Future<dynamic> createGroup(String identifiers, String groupName) async {
    return await _methodChannel.invokeMethod('createGroup',
        <String, dynamic>{'identifiers': identifiers, 'groupName': groupName});
  }
  ///邀请用户进入群聊
  Future<dynamic> inviteGroupMember(String identifiers, String groupId) async {
    return await _methodChannel.invokeMethod('inviteGroupMember',
        <String, dynamic>{'identifiers': identifiers, 'groupId': groupId});
  }
  ///退出群聊
  Future<dynamic> quitGroup( String groupId) async {
    return await _methodChannel.invokeMethod('quitGroup',
        <String, dynamic>{ 'groupId': groupId});
  }
  ///修改群名
  Future<dynamic> modifyGroupName(String groupId,String groupName) async {
    return await _methodChannel.invokeMethod('modifyGroupName',
        <String, dynamic>{ 'groupId': groupId,'groupName': groupName});
  }
  ///修改群公告
  Future<dynamic> modifyGroupNotification(String groupId,String notification) async {
    return await _methodChannel.invokeMethod('modifyGroupNotification',
        <String, dynamic>{ 'groupId': groupId,'notification': notification});
  }
  ///修改群头像
  Future<dynamic> modifyGroupFaceUrl(String groupId,String faceUrl) async {
    return await _methodChannel.invokeMethod('modifyGroupFaceUrl',
        <String, dynamic>{ 'groupId': groupId,'faceUrl': faceUrl});
  }
  ///获取群组成员
  Future<dynamic> getGroupMembers(String groupId) async {
    return await _methodChannel.invokeMethod('getGroupMembers',
        <String, dynamic>{ 'groupId': groupId});
  }
  ///获取群组资料
  Future<dynamic> getGroupInfo(String groupId) async {
    return await _methodChannel.invokeMethod('getGroupInfo',
        <String, dynamic>{ 'groupId': groupId});
  }



}
