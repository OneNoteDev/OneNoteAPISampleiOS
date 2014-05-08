//*********************************************************
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the ""License"");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED ON AN  *AS IS* BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS
// OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
//
// See the Apache Version 2.0 License for specific language
// governing permissions and limitations under the License.
//*********************************************************

#import "ONSCPSCreateExamples.h"
#import <LiveSDK/LiveConnectClient.h>
#import <LiveSDK/LiveConnectSessionStatus.h>
#import "ISO8601DateFormatter.h"
#import "AFURLRequestSerialization.h"
#import "ONSCPSMSAConstants.h"

// Client id for your application from Live Connect application management page
/**
 Visit http://go.microsoft.com/fwlink/?LinkId=392537 for instructions on getting a Client Id
 */
static NSString *const ClientId = @"Insert Your Client Id Here";

// Main Live Connect API object
static LiveConnectClient *liveClient;

//The time when the current access token expires
static NSDate *expires;

//The current access token value
static NSString *accessToken;

//The current refresh token value
static NSString *refreshToken;

// Get a date in ISO8601 string format
NSString* dateInISO8601Format() {
    ISO8601DateFormatter *isoFormatter = [[ISO8601DateFormatter alloc] init];
    [isoFormatter setDefaultTimeZone: [NSTimeZone localTimeZone]];
    [isoFormatter setIncludeTime:YES];
    NSString *date = [isoFormatter stringFromDate:[NSDate date]];
    return date;
}

// Add private extension members
@interface ONSCPSCreateExamples () {
    
    //Callback for app-defined behavior when state changes
    id<ONSCPSExampleDelegate> _delegate;
    
    // Response from the current in-progress request
    NSHTTPURLResponse *returnResponse;
    
    // Data being built for the current in-progress request
    NSMutableData *returnData;
}
@end

@implementation ONSCPSCreateExamples

+ (NSString*)clientId {
    return ClientId;
}

+ (BOOL) isStringEmpty:(NSString *)string {
    if([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

+ (NSString*) getPagesEndpointUrlWithSectionName:(NSString *)sectionName {
    NSString *endpointToRequest;
    if([ONSCPSCreateExamples isStringEmpty:sectionName]) {
            endpointToRequest = PagesEndPoint;
    }
    else {
        endpointToRequest = [NSString stringWithFormat: @"%@%@%@", PagesEndPoint, @"/?sectionName=",sectionName];
    }
    return endpointToRequest;
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<ONSCPSExampleDelegate>)newDelegate {
    self = [super init];
    if(self != nil) {
        if(!liveClient) {
            NSArray *scopeStrings = @[@"wl.signin", @"wl.offline_access", @"Office.OneNote_Create"];
            liveClient = [[LiveConnectClient alloc] initWithClientId:ClientId
                                                          scopes:scopeStrings
                                                        delegate:self
                                                       userState:@"init"];
        }
        _delegate = newDelegate;
    }
    return self;
}

// Get the delegate in use
- (id<ONSCPSExampleDelegate>)delegate {
    return _delegate;
}

// Update the delegate to use
- (void)setDelegate:(id<ONSCPSExampleDelegate>)newDelegate {
    _delegate = newDelegate;
    // Force a refresh on the new delegate with the current state
    [_delegate exampleAuthStateDidChange:liveClient.session];
}

- (void)authenticate:(UIViewController *)controller {
    NSAssert(liveClient != nil, @"The live client object was found to be nil.");
    NSAssert(controller != nil, @"The UI View controller object was found to be nil");
    if (!liveClient.session) {
        [liveClient login:controller delegate:self userState:@"login"];
    }
    else {
        [liveClient logoutWithDelegate:self userState:@"logout"];
    }
}

- (void)authCompleted:(LiveConnectSessionStatus)status session:(LiveConnectSession *)session userState:(id)userState {
    //Initialize the values for the access token, the refresh token and the amount of time in which the token expires after successful completion of authentication
    accessToken = liveClient.session.accessToken;
    refreshToken = liveClient.session.refreshToken;
    expires = liveClient.session.expires;
    [_delegate exampleAuthStateDidChange:session];
}

- (void)authFailed:(NSError *)error userState:(id)userState {
    [_delegate exampleAuthStateDidChange:nil];
}

- (void)checkForAccessTokenExpiration {
    if(refreshToken) {
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:TokenExpirationBuffer];
        NSComparisonResult result = [expires compare:now];
        switch (result) {
            case NSOrderedSame:
            case NSOrderedAscending:
                [self attemptRefreshToken];
                break;
            case NSOrderedDescending:
                break;
            default:
                break;
        }
    }
}

- (void)createSimplePage:(NSString*)sectionName {
    [self checkForAccessTokenExpiration];
    NSString *date = dateInISO8601Format();
    NSString *simpleHtml = [NSString stringWithFormat:
                            @"<html>"
                            "<head>"
                            "<title>A simple page created from basic HTML-formatted text from iOS</title>"
                            "<meta name=\"created\" content=\"%@\" />"
                            "</head>"
                            "<body>"
                            "<p>This is a page that just contains some simple <i>formatted</i> <b>text</b></p>"
                            "</body>"
                            "</html>", date];
    
    NSData *presentation = [simpleHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSString *endpointToRequest = [ONSCPSCreateExamples getPagesEndpointUrlWithSectionName:sectionName];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointToRequest]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = presentation;
    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    
    if (liveClient.session) {
        [request setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)createPageWithImage:(NSString*)sectionName {
    [self checkForAccessTokenExpiration];
    NSString *attachmentPartName = @"pngattachment1";
    NSString *date = dateInISO8601Format();
    UIImage *logo = [UIImage imageNamed:@"Logo"];
    
    NSString *simpleHtml = [NSString stringWithFormat:
                            @"<html>"
                            "<head>"
                            "<title>A simple page with an image from iOS</title>"
                            "<meta name=\"created\" content=\"%@\" />"
                            "</head>"
                            "<body>"
                            "<h1>This is a page with an image on it</h1>"
                            "<img src=\"name:%@\" alt=\"A beautiful logo\" width=\"%.0f\" height=\"%.0f\" />"
                            "</body>"
                            "</html>", date, attachmentPartName, [logo size].width, [logo size].height];
    
    NSData *presentation = [simpleHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSData *image1 = UIImageJPEGRepresentation(logo, 1.0);
    NSString *endpointToRequest = [ONSCPSCreateExamples getPagesEndpointUrlWithSectionName:sectionName];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:endpointToRequest parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData
         appendPartWithHeaders:@{
                                 @"Content-Disposition" : @"form-data; name=\"Presentation\"",
                                 @"Content-Type" : @"text/html"}
         body:presentation];
        [formData
         appendPartWithHeaders:@{
                                 @"Content-Disposition" : [NSString stringWithFormat:@"form-data; name=\"%@\"", attachmentPartName],
                                 @"Content-Type" : @"image/jpeg"}
         body:image1];
    }];
    
    if (liveClient.session) {
        [request setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)createPageWithEmbeddedWebPage:(NSString*)sectionName {
    [self checkForAccessTokenExpiration];
    NSString *embeddedWebPage =
        @"<html>"
        @"<head>"
        @"<title>An embedded webpage</title>"
        @"</head>"
        @"<body>"
        @"<h1>This is a screen grab of a web page</h1>"
        @"<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vehicula magna quis mauris accumsan, nec imperdiet nisi tempus. Suspendisse potenti. "
        @"Duis vel nulla sit amet turpis venenatis elementum. Cras laoreet quis nisi et sagittis. Donec euismod at tortor ut porta. Duis libero urna, viverra id "
        @"aliquam in, ornare sed orci. Pellentesque condimentum gravida felis, sed pulvinar erat suscipit sit amet. Nulla id felis quis sem blandit dapibus. Ut "
        @"viverra auctor nisi ac egestas. Quisque ac neque nec velit fringilla sagittis porttitor sit amet quam.</p>"
        @"</body>"
        @"</html>";
    
    NSString *date = dateInISO8601Format();
    NSString *simpleHtml = [NSString stringWithFormat:
                            @"<html>"
                            "<head>"
                            "<title>A page created with an image of an html page on it from iOS</title>"
                            "<meta name=\"created\" content=\"%@\" />"
                            "</head>"
                            "<body>"
                            "<h1>This is a page with an image of an html page on it.</h1>"
                            "<img data-render-src=\"name:embedded1\" alt=\"A website screen grab\" />"
                            "</body>"
                            "</html>", date];
    
    NSData *presentation = [simpleHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSData *embedded1 = [embeddedWebPage dataUsingEncoding:NSUTF8StringEncoding];
    NSString *endpointToRequest = [ONSCPSCreateExamples getPagesEndpointUrlWithSectionName:sectionName];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:endpointToRequest parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                        [formData
                                                         appendPartWithHeaders:@{
                                                                                 @"Content-Disposition" : @"form-data; name=\"Presentation\"",
                                                                                 @"Content-Type" : @"text/html"}
                                                         body:presentation];
                                                        [formData
                                                         appendPartWithHeaders:@{
                                                                                 @"Content-Disposition" : @"form-data; name=\"embedded1\"",
                                                                                 @"Content-Type" : @"text/html"}
                                                         body:embedded1];
                                                    }];
    if (liveClient.session) {
        [request setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)createPageWithUrl:(NSString*)sectionName {
    [self checkForAccessTokenExpiration];
    NSString *date = dateInISO8601Format();
    NSString *simpleHtml = [NSString stringWithFormat:
                            @"<html>"
                            "<head>"
                            "<title>A page created with an image from a URL on it from iOS</title>"
                            "<meta name=\"created\" content=\"%@\" />"
                            "</head>"
                            "<body>"
                            "<p>This is a page with an image of an html page rendered from a URL on it.</p>"
                            "<img data-render-src=\"http://www.onenote.com\" alt=\"An important web page\"/>"
                            "</body>"
                            "</html>", date];
    
    NSData *presentation = [simpleHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSString *endpointToRequest = [ONSCPSCreateExamples getPagesEndpointUrlWithSectionName:sectionName];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:endpointToRequest parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                        [formData
                                                         appendPartWithHeaders:@{
                                                                                 @"Content-Disposition" : @"form-data; name=\"Presentation\"",
                                                                                 @"Content-Type" : @"text/html"}
                                                         body:presentation];
                                                    }];
    
    if (liveClient.session) {
        [request setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)createPageWithAttachmentAndPdfRendering:(NSString*)sectionName {
    [self checkForAccessTokenExpiration];
    NSString *attachmentPartName = @"pdfattachment1";
    NSURL *attachmentURL = [[NSBundle mainBundle] URLForResource:@"attachment" withExtension:@"pdf"];
    NSString *date = dateInISO8601Format();
    NSData *fileData = [NSData dataWithContentsOfURL: attachmentURL];
    NSString *simpleHtml = [NSString stringWithFormat:
                            @"<html>"
                            "<head>"
                            "<title>A simple page with an attachment from iOS</title>"
                            "<meta name=\"created\" content=\"%@\" />"
                            "</head>"
                            "<body>"
                            "<h1>This is a page with a PDF file attachment</h1>"
                            "<object data-attachment=\"attachment.pdf\" data=\"name:%@\" />"
                            "<p>Here's the contents of the PDF document :</p>"
                            "<img data-render-src=\"name:%@\" alt=\"Hello World\" width=\"1500\" />"
                            "</body>"
                            "</html>", date, attachmentPartName, attachmentPartName];
    
    NSData *presentation = [simpleHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSString *endpointToRequest = [ONSCPSCreateExamples getPagesEndpointUrlWithSectionName:sectionName];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:endpointToRequest parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData
         appendPartWithHeaders:@{
                                 @"Content-Disposition" : @"form-data; name=\"Presentation\"",
                                 @"Content-Type" : @"text/html"}
         body:presentation];
        [formData
         appendPartWithHeaders:@{
                                 @"Content-Disposition" : [NSString stringWithFormat:@"form-data; name=\"%@\"", attachmentPartName],
                                 @"Content-Type" : @"application/pdf"}
         body:fileData];
    }];
    
    if (liveClient.session) {
        [request setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) processRefreshTokenResponse:(NSDictionary *)responseObject {
    accessToken = (NSString *) responseObject[@"access_token"];
    refreshToken = (NSString *) responseObject[@"refresh_token"];
    NSInteger expiresIn = [responseObject[@"expires_in"] integerValue];
    expires = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
}

- (void) attemptRefreshToken {
    NSString *requestBody = [NSString stringWithFormat:@"client_id=%@&redirect_uri=%@&grant_type=refresh_token&refresh_token=%@", ClientId, RefreshTokenRedirectURL, refreshToken];
    NSMutableURLRequest * refreshRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:RefreshTokenEndpoint]];
    refreshRequest.HTTPMethod = @"POST";
    refreshRequest.HTTPBody = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    [refreshRequest setValue:RequestContentType forHTTPHeaderField:@"Content-Type"];
    if (liveClient.session) {
        [refreshRequest setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    }
    NSHTTPURLResponse *refreshTokenResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:refreshRequest returningResponse:&refreshTokenResponse error:nil];
    if (refreshTokenResponse != nil) {
        if ([refreshTokenResponse statusCode] == 200) {
            NSError *jsonError;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (responseObject && !jsonError) {
                [self processRefreshTokenResponse:responseObject];
            }
            else {
                /*
                 Reaching here means that parsing the response object received for the refresh token request failed.
                 This is a placeholder to define error handling as per desired application specific behavior in this event.
                */
            }
        }
        else {
            /*
             Reaching here means that the status code on the response was NOT 200 OK for the refresh token request.
             This is a placeholder for adding application specific handling for not having a successful response for this request.
             */
        }
    }
}




#pragma mark - Delegate callbacks from asynchronous request POST

// Handle send errors
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
     // Error is a failure to make the call or authenticate, not a deep HTTP error response from the server.
     [_delegate exampleServiceActionDidCompleteWithResponse:[[ONSCPSStandardErrorResponse alloc] init]];
}

// When body data arrives, store it
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [returnData appendData:data];
}

// When a response starts to arrive, allocate a data buffer for the body
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    returnData = [[NSMutableData alloc] init];
    returnResponse = (NSHTTPURLResponse *)response;
}

// Handle parsing the response from a finished service call
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    int status = [returnResponse statusCode];
    ONSCPSStandardResponse *standardResponse = nil;
    if (status == 201) {
        ONSCPSCreateSuccessResponse *created = [[ONSCPSCreateSuccessResponse alloc] init];
        created.httpStatusCode = status;
        NSError *jsonError;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonError];
        if(responseObject && !jsonError) {
            created.oneNoteClientUrl = [responseObject valueForKeyPath:@"links.oneNoteClientUrl.href"];
            created.oneNoteWebUrl = [responseObject valueForKeyPath:@"links.oneNoteWebUrl.href"];
        }
        standardResponse = created;
    }
    else {
        ONSCPSStandardErrorResponse *error = [[ONSCPSStandardErrorResponse alloc] init];
        error.httpStatusCode = status;
        error.message = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        standardResponse = error;
    }
    NSAssert(standardResponse != nil, @"The standard response for the connection that finished loading appears to be nil");
    // Send the response back to the client.
    [_delegate exampleServiceActionDidCompleteWithResponse: standardResponse];
}

@end
