//
//  DimModel.h
//  dim
//
//
#import <Foundation/Foundation.h>
#import <ImSDK/ImSDK.h>
NS_ASSUME_NONNULL_BEGIN


@interface DimUser : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *faceURL;
@property (nonatomic, copy) NSString *selfSignature;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, assign) NSInteger birthday;
@property (nonatomic, copy) NSString *location;

+ (DimUser *)initWithTimUser:(TIMUserProfile *)timUserProfile;

@end

@interface DimConversation : NSObject
@property (nonatomic, copy) NSString *identifier;
@property(nonatomic,assign) TIMConversationType conversationType;
@property (nonatomic, copy) NSString *msg;
@property(nonatomic,assign) NSInteger unReadNum;
@property(nonatomic,assign) NSInteger sendTime;

+ (DimConversation *)initWithTIMConversation:(TIMConversation *)timConversation;
@end

@interface DimMessage : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) TIMConversationType conversationType;
@property (nonatomic, strong) TIMElem *message;
@property (nonatomic, assign) int isSelf;
@property (nonatomic, assign) int isRead;
@property(nonatomic,assign) NSInteger sendTime;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *groupName;


+ (DimMessage *)initWithTIMMessage:(TIMMessage *)timMessage;
@end

NS_ASSUME_NONNULL_END
