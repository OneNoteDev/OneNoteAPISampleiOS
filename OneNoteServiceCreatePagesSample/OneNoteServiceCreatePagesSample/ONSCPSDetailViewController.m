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

#import "ONSCPSDetailViewController.h"
#import "ONSCPSCreateExamples.h"

@interface ONSCPSDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation ONSCPSDetailViewController

@synthesize authButton, createButton, responseField, clientLinkField, webLinkField, masterPopoverController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)setExamples:(ONSCPSCreateExamples *)newExample {
    if(_examples != newExample) {
        _examples = newExample;
        [newExample setDelegate:self];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    self.title = [self.detailItem title];
}

- (void) updateSignInButton: (LiveConnectSession *)session
{
    // Can't use self.AuthButton once its been placed on the bar
    UIButton *button = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    if (session == nil)
    {
        [button setTitle:@"Sign in" forState: UIControlStateNormal];
    }
    else
    {
        [button setTitle:@"Sign out" forState: UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Create Examples", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (IBAction)authClicked:(id)sender {
    [self.examples authenticate:self];
}

- (void)exampleAuthStateDidChange:(LiveConnectSession *)session {
    [self updateSignInButton:session];
}

- (IBAction)createClicked:(id)sender {
    // Disable create button to prevent reentrancy
    self.createButton.enabled = NO;
    
    self.responseField.text = @"";
    self.webLinkField.text=@"";
    self.clientLinkField.text=@"";
    
    // Run the action defined for the form in the 'objects' table in the master view controller
    [self.examples performSelector:self.detailItem.implementation];
}

// Service action requested on the examples object has completed
- (void)exampleServiceActionDidCompleteWithResponse:(ONSCPSStandardResponse *)response {
    // Re-enable the create button
    self.createButton.enabled = YES;
    
    if (response) {
        responseField.text = [NSString stringWithFormat:@"%d", response.httpStatusCode];
        if ([response isKindOfClass:[ONSCPSCreateSuccessResponse class]]) {
            ONSCPSCreateSuccessResponse *createSuccess = (ONSCPSCreateSuccessResponse *)response;
            clientLinkField.text = createSuccess.oneNoteClientUrl;
            webLinkField.text = createSuccess.oneNoteWebUrl;
        }
        else {
            clientLinkField.text = @"";
            webLinkField.text = @"";
            
        }
    }
}

- (IBAction)clientLaunchClicked:(id)sender {
    NSURL *url = [NSURL URLWithString: clientLinkField.text];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)webLaunchClicked:(id)sender {
    NSURL *url = [NSURL URLWithString: webLinkField.text];
    [[UIApplication sharedApplication] openURL:url];
}
@end
