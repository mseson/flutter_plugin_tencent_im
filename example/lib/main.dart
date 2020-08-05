import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tim/flutter_tim.dart';

import 'dart:math';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterTim _tim = new FlutterTim();

  String _result = "";

  List<dynamic> _users = List();

  //在另外一个手机上测试改变下用户，靠这里了
  int _currentUser = 2;

//  int appid = 1400215656;
  int appid = 1400182424;

  StreamSubscription<dynamic> _messageStreamSubscription;

  StreamSubscription<dynamic> _conversationStreamSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
//    _users.add({
//      'username': 'hoolly1',
//      'sig':
//          "eJxlj8FPgzAche-8FYTrjLbQgngbbkEmHIgzZF4Iwg*obLTSssmM-7sRNTbxXb8v7*W9G6ZpWtv44bIoSz72KleTAMu8MS1kXfxBIViVFyp3huofhDfBBsiLWsEwQ0wptRHSHVZBr1jNfoyW8-1*wpogqy6fV74bCEI2pi51dYU1M0zWu9soXWUp37Q0CKYoCGJVPi3ASRkbty*CyCQeC7dZc1igFK5OUbvchMdyyvz7tqulF3qrJT3Is-vYvI4nz92hwc-EHQnpM0k6bVKxA-xe8sk19oij0SMMkvF*FmyEKbYd9BXL*DA*AfzTXb0_"
//    });
//    _users.add({
//      'username': 'hoolly2',
//      'sig':
//          "eJxlj8FOg0AURfd8BWFbIzMDM60mLhqUhNpqacUFGwKdgb4yDATGltb470bUSOLbnpN773s3TNO0Xpbb63S3q9*UTvS5EZZ5a1rIuvqDTQM8SXXitPwfFH0DrUjSXIt2gJhSShAaO8CF0pDDj7GvaynPZCR0vEyGlu8EFyGCKaNsrEAxwNVD5AXhPeHk4D1uTq7wudL9pVB9PJmjCmTZ*pn0Q8*3N9sc8qciKBbsGOBYnEo2E5nM9yxmr5FcVwd7MWEdrHHozLPnVbS0w7tRpYZK-L50487wdDrefBRtB7UaBIIwxcRBX2cZH8YnH3NdyQ__"
//    });
//    _users.add({
//      'username': 'hoolly3',
//      'sig':
//          "eJxlj11PgzAARd-5FU2fjbZA2ccbwW0QYbqMEeSlAdpB2YQGyiYx-ncjakbifT0n9*Z*aAAAGPr7*zTPm75WVA2SQ7AEEMG7G5RSMJoqarTsH*TvUrScpkfF2xFiQoiO0NQRjNdKHMWvUTbN*TwYE6FjJzqu-DSYCOmYWMSaKqIYYbB6dbyd40XeY6i8uHpyS5*blzBKtv1zvtrGa9Zd1yeLWb0hrzxyba*0g83eVpsgr5wC6Vl8KHYvWZUmTvdQJ2o4ZHXH0eD77tywJ5NKvPG-SwtzjmeL2YReeNuJph4FHWGCdQN9B2qf2hc3HF5a"
//    });
    _users.add({
      'username': '1288',
      'sig':
      "eJw1j0FvgjAYhv8LV5etLRTLEg9IiEzLgbDNZZem2jo-FdZAJVXjf9cxvD7P4X3ei-fOy2dpDCghrfAb5b16yHvqsXYGGi3kxurmjjGllCD0sKB0bWED-44wNvAWfu4gT4vkLSnsIoKO0rCtkrLA56-5LDyduVPzdNm0U4i0G5Hv0ZbPYpiiBLLxlr3k4QHwsYqrz7zkXVf7cuc*Ur4zWbZKXbtcRPFk8hhTe9HX-zUECGFGAhIM0kKl**4QY*T7bDxwuV7-Hmsr7Mno-u71BhtKTro_"
    });
    _users.add({
      'username': '1151',
      'sig':
      "eJw1j8tygjAARf*FLZ2ahOd01zIwBnQoxaHVTSZI0ASFNI0t1PHfqxS35yzuuWdjtcgfqZS8IlQTS1XGkwGMhxGzXnLFCK01U1cMHcdBANwtr1irec3-HXTgxL-47gqW4TrAWWAWgfh9y4QaqDQXeS8*UbxZl*Kl2zSrw2nuvVofHQ4hSjO8f05Vp0Qalf5PXwxF1CYJkJEn3-0c4gB-u*FgzWg5b-oovo9VDRnrbw02ANBHNrInqfmRjd0uhMBybW-idLvtTq0mepBsvHv5A3r8T0k_"
    });
    _users.add({
      'username': '1143',
      'sig':
      "eJw1j8FygjAURf*FLU6bQEixO9C0ZWpVxDrgJhPJQ1MGiBgdHaf-Xou4PWdxz71ay0nyJLRWkgvD3VZarxayBh2Gs1YtcFEYaG8Ye57nIPSwSkJtVKHuDhO35we1vYEvlo2ieDxJBSym2QsVlMr82Q6K02gz3M8*dTMu10pjzQic7JKtgmgXzNm*Xbjp2b7I4SGe*l74va0-YJf9xOVm-RYmtCreKxaukvQxJkve1f83EISw7xCH9NKoCrpuijEiyMc9F3neHGvDzUVDd-f3DwzSTrM_"
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _tim.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (_messageStreamSubscription == null) {
      _messageStreamSubscription = _tim.onMessage.listen((dynamic onData) {
        print("我监听到消息了 $onData");
      });

    }

    if(_conversationStreamSubscription == null){
      _conversationStreamSubscription = _tim.onConversation.listen((dynamic onData){
        print("我监听到会话了 $onData");
      });
    }


  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //flutter 这里应该页面退出栈会调用，但是如果这个是根页面，日志是打不出来的。
    canCelListener();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('当前账号' + _users[_currentUser]["username"]),
        ),
        body: new Center(
          child: CustomScrollView(
            primary: false,
            slivers: <Widget>[
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                    minHeight: 30,
                    maxHeight: 200,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: SingleChildScrollView(
                        child: Text(_result.isEmpty ? "这里显示输出结果" : _result),
                      ),
                    )),
                pinned: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverGrid.count(
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  crossAxisCount: 4,
                  children: <Widget>[

                    RaisedButton(
                      onPressed: () {
                        login();
                      },
                      child: Text('登录'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        logout();
                      },
                      child: Text('登出'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        sendTextMsg();
                      },
                      child: Text('发文本'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        sendImageMsg();
                      },
                      child: Text('发图片'),
                    ),

                    RaisedButton(
                      onPressed: () {
                        getMessages();
                      },
                      padding: EdgeInsets.all(0),
                      child: Text('历史消息'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        getUserInfo();
                      },
                      child: Text('拿资料'),
                    ),

                    RaisedButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        getConversations();
                      },
                      child: Text('会话列表'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> sendTextMsg() async {
    try {
      var result = await _tim.sendTextMessages(
          '1288', "hi 我是张得帅  0719");
      print(result);
      setState(() {
        this._result = result;
      });
    } on PlatformException {
      print("发送消息失败");
      setState(() {
        this._result = "发送消息失败";
      });
    }
  }

  Future<void> sendImageMsg() async {
    try {
      var result = await _tim.sendImageMessages(
          _users[_users.length - _currentUser - 1]['username'],
          "tyyhuiijkoi.png");
      print(result);
      setState(() {
        this._result = result;
      });
    } on PlatformException {
      print("发送图片消息失败");
      setState(() {
        this._result = "发送图片消息失败";
      });
    }
  }





  ///第一个测试账号
  Future<void> login() async {
    try {
      var result = await _tim.imLogin(appid,
          _users[_currentUser]['username'], _users[_currentUser]['sig']);
      print(result);
      setState(() {
        this._result = result;
      });
    } on PlatformException {
      print("登录  失败");
    }
  }

  Future<void> logout() async {
    try {
      var result = await _tim.sdkLogout();
      print(result);
      setState(() {
        this._result = result;
      });
    } on PlatformException {
      print("登出  失败");
    }
  }

  Future<dynamic> getMessages() async {
    try {
      var result = await _tim.getMessages(
        _users[_users.length - _currentUser - 1]['username'],
      );
      print(result);
      setState(() {
        this._result = result;
      });
    } on PlatformException {}
  }

  void canCelListener() {
    if (_messageStreamSubscription != null) {
      _messageStreamSubscription.cancel();
    }
    if (_conversationStreamSubscription != null) {
      _conversationStreamSubscription.cancel();
    }
  }

  void getUserInfo() async {
//    try {
//      List<String> users = List();
//      users.add(_users[_users.length - _currentUser - 1]['username']);
//      var result = await _tim.getUsersProfile(users);
//      print(result);
//      setState(() {
//        this._result = result;
//      });
//    } on PlatformException {
//      print("获取个人资料失败");
//    }
  }

  void setUserInfo() async {
//    try {
//      var result = await _tim.setUsersProfile(
//          1, "hz", "https://www.brzhang.club/images/hz.png");
//      print(result);
//      setState(() {
//        this._result = result;
//      });
//    } on PlatformException {
//      print("获取个人资料失败");
//    }
  }

  void getConversations() async {
    try {
      var result = await _tim.getConversationList();
      print(result);
      setState(() {
        this._result = result;
      });
    } on PlatformException {
      print("获取会话列表失败");
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
