

//  Created by Dharmesh Vaghani on 23/07/15
//  Copyright © 2015 Dharmesh Vaghani. All rights reserved.


#import "RequestManager.h"


@implementation RequestManager

@synthesize delegate, commandName;

- (NSString *) urlEncode:(NSString *)str {
    NSString *string = str;
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

-(NSString *)getString:(NSMutableDictionary *)params{
    if (params!=nil){
        NSString *postStr=@"";
        for(int i=0;i<[params count];i++){
            NSString *key = [[[params allKeys] objectAtIndex:i] description];
            postStr = [postStr stringByAppendingString:key];
            postStr = [postStr stringByAppendingString:@"="];
            postStr = [postStr stringByAppendingString:[NSString stringWithFormat:@"%@",[params objectForKey:key]]];
            if(i < [params count] - 1)
                postStr = [postStr stringByAppendingString:@"&"];
        }
        NSString *str=[NSString stringWithFormat:@"?%@",postStr];
        return [self urlEncode:str];
    }else{
        return @"";
    }
}

-(NSString *)postString:(NSDictionary *)params{
    if (params!=nil){
        NSString *postStr=@"";
        for(int i=0;i<[[params allKeys] count];i++){
            NSString *key = [[[params allKeys] objectAtIndex:i] description];
            postStr = [postStr stringByAppendingString:@"&"];
            postStr = [postStr stringByAppendingString:key];
            postStr = [postStr stringByAppendingString:@"="];
            postStr = [postStr stringByAppendingString:[NSString stringWithFormat:@"%@",[params objectForKey:key]]];
        }
        return postStr;
    }else{
        return @"";
    }
}



-(void)callGetURL:(NSString *)url parameters:(NSMutableDictionary *)params{
    NSString *parStr =[self getString:params];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", url,parStr];
    NSLog(@"get requestUrl %@",requestUrl);
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    
    theRequest.timeoutInterval = 120;
    
    [theRequest setHTTPMethod:HTTP_GET_METHOD];
    NSURLConnection *theconnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    
    if (theconnection) {
        receivedData = [NSMutableData data];
    }else{
    }
}

-(void)callDeleteURL:(NSString *)url parameters:(NSMutableDictionary *)params{
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    NSString *parStr =[self getString:params];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", url,parStr];
    NSLog(@"delete requestUrl %@",requestUrl);
    [theRequest setHTTPMethod:HTTP_DELETE_METHOD];
    NSURLConnection *theconnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    
    if (theconnection) {
        receivedData = [NSMutableData data];
    }else{
    }
}

-(void)callPutURL:(NSString *)url parameters:(NSMutableDictionary *)params{
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:HTTP_PUT_METHOD];
    NSString *parStr =[self postString:params];
    NSLog(@"put parStr %@",parStr);
    
    NSData *data = [parStr dataUsingEncoding:NSASCIIStringEncoding];
    [theRequest setHTTPBody:data];
    
    NSURLConnection *theconnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    
    if (theconnection) {
        receivedData = [NSMutableData data];
    }else{
    }
}

-(void)callPostURL:(NSString *)url parameters:(NSString *)params{
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:HTTP_POST_METHOD];
    
    NSLog(@"url %@", url);
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [theRequest setHTTPBody:data];
    
    // set Content-Type in HTTP header
    [theRequest setValue:@"text/html; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    
    NSURLConnection *theconnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    
    if (theconnection) {
        receivedData = [NSMutableData data];
    }else{
    }
}

- (void)callPhotoUpload:(NSString *)url parameters:(NSMutableDictionary *)_params imageData:(NSData *)imageData photoKey:(NSString *)photoKey
{
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", photoKey] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithData:imageData]];
    
    //        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrImages];
    //        [body appendData:data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    //    [request setURL:requestURL];
    
    NSURLConnection *theconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if (theconnection) {
        receivedData = [NSMutableData data];
    }else{
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    
    NSLog(@"%@", error.localizedDescription);
    
    [delegate onFault:error];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        //        if ([trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    NSError *error = nil;
    NSString *responseStr = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    NSLog(@"responseStr %@", responseStr);
    id dict = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Result %@ \n Error : %@", dict, error.description);
    
    BOOL isTrue = true;
    
    if([dict isKindOfClass:[NSNumber class]]) {
        isTrue = false;
    }
    
    [delegate onResult:dict action:commandName isTrue:isTrue];
}

-(NSMutableArray *)parseResults:(NSString *)result{
    NSMutableArray *dataDictionaryArray = [[NSMutableArray alloc] init];
    
    return dataDictionaryArray;
}


@end
