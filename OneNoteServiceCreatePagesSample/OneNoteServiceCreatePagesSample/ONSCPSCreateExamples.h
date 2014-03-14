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

#import <Foundation/Foundation.h>
#import <LiveSDK/LiveAuthDelegate.h>
#import "ONSCPSExampleDelegate.h"
#import "ONSCPSStandardResponse.h"

@interface ONSCPSCreateExamples : NSObject <LiveAuthDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (NSString*) getClientId;

// Initialize the class with a delegate for state changes
- (id)initWithDelegate:(id<ONSCPSExampleDelegate>)newDelegate;

// Get the delegate in use
-(id<ONSCPSExampleDelegate>) delegate;

// Update the delegate to use
- (void)setDelegate:(id<ONSCPSExampleDelegate>)newDelegate;

// Authenticate against Live Connect passing a controller to host the auth UI on.
- (void)authenticate:(UIViewController *)controller;

// Five samples of creating pages
- (void)createSimplePage;
- (void)createPageWithImage;
- (void)createPageWithEmbeddedWebPage;
- (void)createPageWithUrl;
- (void)createPageWithAttachment;

@end
