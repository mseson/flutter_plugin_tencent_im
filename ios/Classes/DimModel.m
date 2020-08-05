//
//  DimModel.m
//  dim
//
#import "DimModel.h"

@implementation DimUser

+ (DimUser *)initWithTimUser:(TIMUserProfile *)timUserProfile {
    DimUser *dimUser = [[DimUser alloc]init];
    dimUser.identifier = timUserProfile.identifier;
    dimUser.nickName = timUserProfile.nickname;
    dimUser.faceURL = timUserProfile.faceURL;
    dimUser.selfSignature = [[NSString alloc]initWithData:timUserProfile.selfSignature  encoding:NSUTF8StringEncoding];
    dimUser.gender = timUserProfile.gender ? timUserProfile.gender : 1;
    dimUser.birthday = timUserProfile.birthday;
    dimUser.location = [[NSString alloc]initWithData:timUserProfile.location  encoding:NSUTF8StringEncoding];
    return dimUser;
}

@end

@implementation DimConversation

+ (DimConversation *)initWithTIMConversation:(TIMConversation *)timConversation {
    
    DimConversation *dimConversation = [[DimConversation alloc]init];
    dimConversation.identifier = timConversation.getReceiver;
    

    dimConversation.conversationType = timConversation.getType;
    dimConversation.unReadNum = timConversation.getUnReadMessageNum;
    TIMMessage *lastMsg = timConversation.getLastMsg;
    TIMElem *elem = [lastMsg getElem:0];
    NSString * msg = @"";
    if ([elem isKindOfClass:[TIMTextElem class]]) {
        TIMTextElem * text_elem = (TIMTextElem * )elem;
        msg = text_elem.text;
    }
    else if ([elem isKindOfClass:[TIMImageElem class]]) {
        msg = @"[图片]";
    }
    else if ([elem isKindOfClass:[TIMSoundElem class]]){
        msg = @"[语音]";
    }
    else if ([elem isKindOfClass:[TIMVideoElem class]]){
        msg = @"[视频]";
    }
    else if ([elem isKindOfClass:[TIMFileElem class]]){
        msg = @"[文件]";
    }
    dimConversation.msg = msg;
    
    NSDate *date = lastMsg.timestamp;
//    NSTimeInterval seconds = [date timeIntervalSinceReferenceDate];
    NSTimeInterval seconds = [date timeIntervalSince1970];
//    double milliseconds = seconds*1000;
    NSNumber *time = [NSNumber numberWithDouble:seconds];
    NSInteger timestamp = [time integerValue];
    dimConversation.sendTime = timestamp;
    
    
    
    return dimConversation;
}
@end

@implementation DimMessage

+ (DimMessage *)initWithTIMMessage:(TIMMessage *)timMessage {
    DimMessage *dimMessage = [[DimMessage alloc]init];
    dimMessage.identifier = timMessage.sender;
    dimMessage.conversationType = timMessage.getConversation.getType;
    dimMessage.message = [timMessage getElem:0];
    dimMessage.isRead = timMessage.isReaded?1:0;
    dimMessage.isSelf = timMessage.isSelf?1:0;
   
    NSDate *date = timMessage.timestamp;
//    NSTimeInterval seconds = [date timeIntervalSinceReferenceDate];
    NSTimeInterval seconds = [date timeIntervalSince1970];
//    double milliseconds = seconds*1000;
    NSNumber *time = [NSNumber numberWithDouble:seconds];
    NSInteger timestamp = [time integerValue];
    dimMessage.sendTime = timestamp;
    
    [timMessage getSenderProfile:^(TIMUserProfile *proflie) {
        dimMessage.sender =  proflie.identifier;
    }];
    
    dimMessage.groupName = timMessage.getConversation.getGroupName;
    
    TIMElem *elem = [timMessage getElem:0];

    NSInteger  type = 0;
    if ([elem isKindOfClass:[TIMTextElem class]]) {
        type = 1;
    }
    else if ([elem isKindOfClass:[TIMImageElem class]]) {
        type = 4;
    }
    else if ([elem isKindOfClass:[TIMSoundElem class]]){
        type = 5;
    }
    else if([elem isKindOfClass:[TIMCustomElem class]]){
        type = 6;
    }else if ([elem isKindOfClass:[TIMFileElem class]]){
        type = 7;
    }
    else if ([elem isKindOfClass:[TIMGroupTipsElem class]]){
        type = 9;
    }
    else if ([elem isKindOfClass:[TIMFaceElem class]]){
        type = 10;
    }
    else if ([elem isKindOfClass:[TIMLocationElem class]]){
        type = 11;
    }
    else if ([elem isKindOfClass:[TIMGroupSystemElem class]]){
        type = 12;
    }
    else if ([elem isKindOfClass:[TIMSNSSystemElem class]]){
        type = 13;
    }else if ([elem isKindOfClass:[TIMProfileSystemElem class]]){
        type = 14;
    }
    else if ([elem isKindOfClass:[TIMVideoElem class]]){
        type = 15;
    }
    
    dimMessage.type = type;
    
    return dimMessage;
}
@end
