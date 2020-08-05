#import "FlutterTimPlugin.h"
#import "MJExtension.h"
#import <ImSDK/ImSDK.h>
#import "DimModel.h"
#import "YYModel.h"
@class MessageStreamHandler;

//@class GroupStreamHandler;

@interface FlutterTimPlugin() <TIMConnListener, TIMUserStatusListener, TIMMessageListener>

@property (nonatomic, strong) MessageStreamHandler *messageStreamHandler;

//@property (nonatomic, strong) GroupStreamHandler *groupStreamHandler;
@end

@interface MessageStreamHandler : NSObject<FlutterStreamHandler>

@property (nonatomic, strong) FlutterEventSink messageEventSink;

- (void) sendMessage:(NSString *)message;

@end




@implementation MessageStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    
    self.messageEventSink = eventSink;
    
    return nil;
    
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    
    self.messageEventSink = nil;
    
    return nil;
    
}

- (void) sendMessage:(NSString *)message {
    
    if(self.messageEventSink) {
        self.messageEventSink(message);
    }
    
}

@end

//
//@interface GroupStreamHandler : NSObject <FlutterStreamHandler>
//
//@property (nonatomic, strong) FlutterEventSink groupEventSink;
//
//- (void) sendGroupTips:(NSString *)groupTips;
//
//@end
//
//@implementation GroupStreamHandler
//
//- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
//
//    self.groupEventSink = eventSink;
//
//    return nil;
//
//}
//
//- (FlutterError*)onCancelWithArguments:(id)arguments {
//
//    self.groupEventSink = nil;
//
//    return nil;
//
//}
//
//- (void) sendGroupTips:(NSString *)groupTips {
//
//    if(self.groupEventSink) {
//
//        self.groupEventSink(groupTips);
//
//    }
//
//}
//
//@end



@implementation FlutterTimPlugin{
    
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"tim_method"
            binaryMessenger:[registrar messenger]];
  FlutterTimPlugin* instance = [[FlutterTimPlugin alloc] init];
    
  [registrar addMethodCallDelegate:instance channel:channel];
    
    // Event channel for messageStream
    
    instance.messageStreamHandler = [MessageStreamHandler new];
    
    FlutterEventChannel *messageEventChannel = [FlutterEventChannel eventChannelWithName:@"tim_event_msg" binaryMessenger:[registrar messenger]];
    [messageEventChannel setStreamHandler: instance.messageStreamHandler];
    
    // Event channel for conversationStream
    
//    instance.groupStreamHandler = [GroupStreamHandler new];
    
//    FlutterEventChannel *groupEventChannel = [FlutterEventChannel eventChannelWithName:@"tim_event_group" binaryMessenger:[registrar messenger]];
//    [groupEventChannel setStreamHandler: instance.groupStreamHandler];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if([@"imLogin" isEqualToString:call.method]){//登录初始化开始

        NSString *appId = (NSString *)call.arguments[@"sdkAppId"];
      
        NSString *identifier = (NSString *)(call.arguments[@"identifier"]);
        NSString *userSig = (NSString *)(call.arguments[@"userSig"]);
        
        //初始化 SDK 基本配置
        TIMSdkConfig *config = [TIMSdkConfig new];
        config.sdkAppId = [appId intValue];
        config.connListener = self;
        
        //初始化 SDK
        [[TIMManager sharedInstance] initSdk:config];
        //将用户配置与通讯管理器进行绑定
        TIMUserConfig *userConfig = [TIMUserConfig new];
        userConfig.userStatusListener = self;
        userConfig.refreshListener = self;
        [[TIMManager sharedInstance] setUserConfig:userConfig];
        [[TIMManager sharedInstance] addMessageListener:self];
        TIMLoginParam *login_param = [[TIMLoginParam alloc ]init];
        // identifier 为用户名，userSig 为用户登录凭证
        // appidAt3rd 在私有帐号情况下，填写与 sdkAppId 一样
        login_param.identifier = identifier;
        login_param.userSig = userSig;
        //      login_param.appidAt3rd = appId;
        [[TIMManager sharedInstance] login: login_param succ:^(){
            result(@"Login Succ");
        } fail:^(int code, NSString * err) {
            NSLog(@"Login Failed: %d->%@", code, err);
            result([NSString stringWithFormat:@"Login Failed: %d->%@", code, err]);
        }];
    }
    //登录初始化结束
    //退出
    else if ([ @"imLogout" isEqualToString:call.method] ){
        [[TIMManager sharedInstance] logout:^{
            result(@"Logout Succ");
        } fail:^(int code, NSString *msg) {
            result([NSString stringWithFormat:@"Login Failed: %d->%@", code, msg]);
        }];
    }
    //获取当前登录用户
    else if([ @"getLoginUser" isEqualToString:call.method]){
        result([[TIMManager sharedInstance] getLoginUser]);
    }
    //已读消息上报 C2C
    else if([ @"setReadMessage" isEqualToString:call.method]){
        NSString *identifier = call.arguments[@"identifier"];
        TIMConversation * conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:identifier];
        [conversation setReadMessage:nil succ:nil fail:nil];
        
    }//获取离线消息
    else if ([ @"getLocalMessages" isEqualToString:call.method]){
        NSString *identifier = call.arguments[@"identifier"];
        //初始化本地存储
        [[TIMManager sharedInstance] initStorage: identifier succ:^(){
            NSLog(@"Init Succ");
        } fail:^(int code, NSString * err) {
            NSLog(@"Init Failed: %d->%@", code, err);
        }];
        
        TIMConversation *con = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:identifier];
        [con getLocalMessage:20 last:NULL succ:^(NSArray *msgs) {
            if(msgs != nil && msgs.count > 0){
                NSMutableArray *dictArray = [[NSMutableArray alloc]init];
                for (TIMMessage *message in msgs) {
                    DimMessage *dimMessage = [DimMessage initWithTIMMessage:message];
                    [dictArray addObject:dimMessage];
                }
                NSString *jsonString = [dictArray yy_modelToJSONString];
                result(jsonString);
            }else{
                result(@"[]");
            }

        } fail:^(int code, NSString *msg) {
            result([NSString stringWithFormat:@"get message failed. code: %d msg: %@", code, msg]);
        }];        
    }
    //获取会话列表
    else if([@"getConversationList" isEqualToString:call.method]){
        
        NSArray *conversationList = [[TIMManager sharedInstance] getConversationList];
        if (conversationList!=nil && conversationList.count>0) {
            NSMutableArray *dictArray = [[NSMutableArray alloc]init];
            for (TIMConversation *conversation in conversationList) {
                DimConversation *dimConversation = [DimConversation initWithTIMConversation:conversation ];
                [dictArray addObject:dimConversation];
            }
            NSString *jsonString = [dictArray yy_modelToJSONString];
            result(jsonString);
        }else{
            result(@"[]");
        }
    }else if([@"deleteConversation" isEqualToString:call.method]){
        NSString *identifier = call.arguments[@"identifier"];
        [[TIMManager sharedInstance] deleteConversation:TIM_C2C receiver:identifier];
        result(@"delConversation success");
    }else if([@"getMessages" isEqualToString:call.method]){
        NSString *identifier = call.arguments[@"identifier"];
//        int count = [call.arguments[@"count"] intValue];
        int ctype = [call.arguments[@"ctype"] intValue];
        //TIMMessage *lastMsg = call.arguments[@"lastMsg"];
        TIMConversation *con = [[TIMManager sharedInstance] getConversation: ctype==2 ? TIM_GROUP:TIM_C2C receiver:identifier];
        [con getMessage:20 last:NULL succ:^(NSArray *msgs) {
            if(msgs != nil && msgs.count > 0){
                NSMutableArray *dictArray = [[NSMutableArray alloc]init];
                for (TIMMessage *message in msgs) {
                    DimMessage *dimMessage = [DimMessage initWithTIMMessage:message];
                    [dictArray addObject:dimMessage];
                }
                NSString *jsonString = [dictArray yy_modelToJSONString];
                result(jsonString);
            }else{
                result(@"[]");
            }
        } fail:^(int code, NSString *msg) {
            result([NSString stringWithFormat:@"get message failed. code: %d msg: %@", code, msg]);
        }];
    }else if([@"sendTextMessages" isEqualToString:call.method]){
        NSString *identifier = call.arguments[@"identifier"];
        NSString *conversationType = call.arguments[@"conversationType"];
        NSString *content = call.arguments[@"content"];
        TIMMessage *msg = [TIMMessage new];
        
        //添加文本内容
        TIMTextElem *elem = [TIMTextElem new];
        elem.text = content;
        
        //将elem添加到消息
        if([msg addElem:elem] != 0){
            NSLog(@"addElement failed");
            return;
        }
        TIMConversation *conversation = NULL;
        if(1 == [conversationType intValue]){
            conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:identifier];
        }else{
            conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:identifier];
        }
        //发送消息
        [conversation sendMessage:msg succ:^{
            DimMessage *dimMessage = [DimMessage initWithTIMMessage:msg];
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"data\": %@ }", 1,[dimMessage yy_modelToJSONString] ];

            result(rst);
        } fail:^(int code, NSString *msg) {
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d}", 0, code];
            result(rst);
        }];
    }else if([@"sendImageMessages" isEqualToString:call.method]){
        NSString *identifier = call.arguments[@"identifier"];
        NSString *conversationType = call.arguments[@"conversationType"];
        NSString *iamgePath = call.arguments[@"image_path"];
        //构造一条消息
        TIMMessage *msg = [TIMMessage new];
        
        //添加图片
        TIMImageElem *elem = [TIMImageElem new];
        elem.path = iamgePath;
        if([msg addElem:elem] != 0){
            NSLog(@"addElement failed");
        }
        
        TIMConversation *conversation = NULL;
        if(1 == [conversationType intValue]){
            conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:identifier];
        }else{
            conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:identifier];
        }
        [conversation sendMessage:msg succ:^{
            DimMessage *dimMessage = [DimMessage initWithTIMMessage:msg];
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"data\": %@}", 1,[dimMessage yy_modelToJSONString] ];
            result(rst);
            
        } fail:^(int code, NSString *msg) {
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d}", 0, code];
            result(rst);
            
        }];
        
    }//创建私有群聊
    else if([@"createGroup" isEqualToString:call.method]){
        NSMutableArray * members = [[NSMutableArray alloc] init];
        
        NSString *identifiers = call.arguments[@"identifiers"];
        NSString *groupName = call.arguments[@"groupName"];

        NSArray *identifierArrary = [identifiers componentsSeparatedByString:@","];
        for(NSString *identifier in identifierArrary){
            // 添加一个用户
            [members addObject:identifier];
        }
        [[TIMGroupManager sharedInstance] createPrivateGroup:members groupName:groupName succ:^(NSString * group) {
            NSLog(@"create group succ, sid=%@", group);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"groupId\": \"%@\"}", 1, group];
            result(rst);
        } fail:^(int code, NSString* err) {
            NSLog(@"create group failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);
        }];
    }//邀请用户入群
    else if([@"inviteGroupMember" isEqualToString:call.method]){
        NSMutableArray * members = [[NSMutableArray alloc] init];
        NSString *identifiers = call.arguments[@"identifiers"];
        NSString *groupId = call.arguments[@"groupId"];

        // 添加一个用户 iOS_002
        NSArray *identifierArrary = [identifiers componentsSeparatedByString:@","];
        for(NSString *identifier in identifierArrary){
            // 添加一个用户
            [members addObject:identifier];
        }        // @"TGID1JYSZEAEQ" 为群组 ID
        [[TIMGroupManager sharedInstance] inviteGroupMember:groupId members:members succ:^(NSArray* arr) {
            for (TIMGroupMemberResult * result in arr) {
                NSLog(@"user %@ status %d", result.member, result.status);
            }
            result([NSString stringWithFormat:@"{\"success\":%d", 1]);
        } fail:^(int code, NSString* err) {
            NSLog(@"failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);
        }];
    }//退出群聊
    else if([@"quitGroup" isEqualToString:call.method]){
        NSString *groupId = call.arguments[@"groupId"];
        [[TIMGroupManager sharedInstance] quitGroup:groupId succ:^() {
            NSLog(@"succ");
            result([NSString stringWithFormat:@"{\"success\":%d", 1]);
        } fail:^(int code, NSString* err) {
            NSLog(@"failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);
        }];
        
    }//修改群名
    else if([@"modifyGroupName" isEqualToString:call.method]){
        NSString *groupId = call.arguments[@"groupId"];
        NSString *groupName = call.arguments[@"groupName"];

        [[TIMGroupManager sharedInstance] modifyGroupName:groupId groupName:groupName succ:^() {
            NSLog(@"modify group name succ");
            result([NSString stringWithFormat:@"{\"success\":%d", 1]);

        }fail:^(int code, NSString* err) {
            NSLog(@"failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);
        }];
        
    }//修改群公告
    else if([@"modifyGroupNotification" isEqualToString:call.method]){
        NSString *groupId = call.arguments[@"groupId"];
        NSString *notification = call.arguments[@"notification"];
        [[TIMGroupManager sharedInstance] modifyGroupNotification:groupId notification:notification succ:^() {
            result([NSString stringWithFormat:@"{\"success\":%d", 1]);
            
            NSLog(@"modify group notification succ");
        }fail:^(int code, NSString* err) {
            NSLog(@"failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);
        }];
        
    }//修改群头像
    else if([@"modifyGroupFaceUrl" isEqualToString:call.method]){
        NSString *groupId = call.arguments[@"groupId"];
        NSString *faceUrl = call.arguments[@"faceUrl"];
        [[TIMGroupManager sharedInstance] modifyGroupFaceUrl:groupId url:faceUrl succ:^() {
            result([NSString stringWithFormat:@"{\"success\":%d", 1]);
            
            NSLog(@"modify group notification succ");
        }fail:^(int code, NSString* err) {
            NSLog(@"failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);
        }];
        
    }//获取群组成员
    else if([@"getGroupMembers" isEqualToString:call.method]){
        NSString *groupId = call.arguments[@"groupId"];
        [[TIMGroupManager sharedInstance] getGroupMembers:groupId succ:^(NSArray* list) {
            NSString *jsonString = [list yy_modelToJSONString];
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"data\": %@ }", 1,jsonString ];
            result(rst);
        } fail:^(int code, NSString * err) {
            NSLog(@"failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);
        }];
    }//获取群组资料
    else if([@"getGroupInfo" isEqualToString:call.method]){
        NSString *groupId = call.arguments[@"groupId"];
        NSMutableArray * groupList = [[NSMutableArray alloc] init];
        [groupList addObject:groupId];
        
        [[TIMGroupManager sharedInstance] getGroupInfo:groupList succ:^(NSArray * groups) {
            NSString *jsonString = [groups yy_modelToJSONString];
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"data\": %@ }", 1,jsonString ];
            result(rst);
        } fail:^(int code, NSString* err) {
            NSLog(@"failed code: %d %@", code, err);
            NSString *rst = [NSString stringWithFormat:@"{\"success\":%d,\"code\": %d,\"msg\":%@}", 0, code,err];
            result(rst);        }];
        
    }
    else {
    result(FlutterMethodNotImplemented);
  }
}



#pragma mark - TIMMessageListener
/**
 *  新消息回调通知
 *
 *  @param msgs 新消息列表，TIMMessage 类型数组
 */
- (void)onNewMessage:(NSArray*)msgs{
    if(msgs != nil && msgs.count > 0){
        NSMutableArray *dictArray = [[NSMutableArray alloc]init];
        for (TIMMessage *message in msgs) {
            DimMessage *dimMessage = [DimMessage initWithTIMMessage:message];
            [dictArray addObject:dimMessage];
        }
        NSString *jsonString = [dictArray yy_modelToJSONString];
        [self.messageStreamHandler sendMessage:jsonString];
    }
}
#pragma mark - TIMGroupEventListener
//-(void) onGroupTipsEvent:(TIMGroupTipsElem *)elem{
//    [self.groupStreamHandler sendGroupTips:[elem yy_modelToJSONString]];
//}
#pragma mark - TIMRefreshListener
/**
 *  会话列表变动
 */
//- (void)onRefresh{
//    NSArray *conversationList = [[TIMManager sharedInstance] getConversationList];
//    if (conversationList!=nil && conversationList.count>0) {
//        NSMutableArray *dictArray = [[NSMutableArray alloc]init];
//        for (TIMConversation *conversation in conversationList) {
//            DimConversation *dimConversation = [DimConversation initWithTIMConversation:conversation ];
//            [dictArray addObject:dimConversation];
//        }
//        NSString *jsonString = [dictArray yy_modelToJSONString];
//        [self.conversationStreamHandler sendConversation:jsonString];
//    }else{
//    }

//}
//-(void) onRefreshConversations:(NSArray *)conversations{
//    NSMutableArray *dictArray = [[NSMutableArray alloc]init];
//    for (TIMConversation *conversation in conversations) {
//        DimConversation *dimConversation = [DimConversation initWithTIMConversation:conversation ];
//        [dictArray addObject:dimConversation];
//    }
//    NSString *jsonString = [dictArray yy_modelToJSONString];
//    [self.conversationStreamHandler sendConversation:jsonString];
//}
@end
