

//  Created by Dharmesh Vaghani on 23/07/15.
//  Copyright © 2015 Dharmesh Vaghani. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "SBJSON.h"

#define HTTP_GET_METHOD      @"GET"
#define HTTP_PUT_METHOD      @"PUT"
#define HTTP_POST_METHOD     @"POST"
#define HTTP_DELETE_METHOD   @"DELETE"
#define COMMAND         @"command"

@protocol RequestManagerDelegate;

@interface RequestManager : NSObject {
    NSMutableData *receivedData;
    id<RequestManagerDelegate> delegate;
    NSString *commandName;
}

@property (nonatomic, retain) id<RequestManagerDelegate> delegate;
@property (nonatomic, retain) NSString *commandName;

-(void)callPostURL:(NSString *)url parameters:(NSString *)params;

- (void)callPhotoUpload:(NSString *)url parameters:(NSMutableDictionary *)_params imageData:(NSData *)imageData photoKey:(NSString *)photoKey;

-(void)callGetURL:(NSString *)url parameters:(NSMutableDictionary *)params;
-(void)callPutURL:(NSString *)url parameters:(NSMutableDictionary *)params;
-(void)callDeleteURL:(NSString *)url parameters:(NSMutableDictionary *)params;

-(NSString *)postString:(NSDictionary *)Params;
-(NSString *)getString:(NSMutableDictionary *)Params;

-(NSMutableArray *)parseResults:(NSString *)result;
-(NSString *) urlEncode:(NSString *)str;

@end

@protocol RequestManagerDelegate
- (void)onResult:(id)result action:(NSString *)action isTrue:(BOOL)isTrue;
- (void)onFault:(NSError *)error;
@end
