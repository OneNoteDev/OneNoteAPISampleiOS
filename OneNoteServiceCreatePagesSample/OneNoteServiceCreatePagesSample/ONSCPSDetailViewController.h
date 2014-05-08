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

#import <UIKit/UIKit.h>
#import <LiveSDK/LiveConnectSession.h>
#import "ONSCPSDataItem.h"
#import "ONSCPSExampleDelegate.h"
#import "ONSCPSCreateExamples.h"

@interface ONSCPSDetailViewController : UIViewController <UISplitViewControllerDelegate, ONSCPSExampleDelegate, UITextFieldDelegate>

@property (strong, nonatomic) ONSCPSDataItem *detailItem;

// Service facade this controller will use
@property (strong, nonatomic) ONSCPSCreateExamples *examples;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *authButton;
@property (strong, nonatomic) IBOutlet UITextField *sectionNameField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UITextField *responseField;
@property (weak, nonatomic) IBOutlet UITextField *clientLinkField;
@property (weak, nonatomic) IBOutlet UITextField *webLinkField;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (IBAction)authClicked:(id)sender;
- (IBAction)createClicked:(id)sender;
- (IBAction)clientLaunchClicked:(id)sender;
- (IBAction)webLaunchClicked:(id)sender;

@end
