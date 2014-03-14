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

#import "ONSCPSMasterViewController.h"

#import "ONSCPSDetailViewController.h"
#import "ONSCPSDataItem.h"
#import "ONSCPSCreateExamples.h"

@interface ONSCPSMasterViewController () {
    NSArray *objects;
    // Service facade instance for the app.
    ONSCPSCreateExamples *examples;
}
@end

@implementation ONSCPSMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self createSampleData];
    
    self.detailViewController = (ONSCPSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [self.tableView reloadData];
    
    // Setup for ipad, where detail view is availabe immediately
    if(self.detailViewController)
    {
        examples = [[ONSCPSCreateExamples alloc] initWithDelegate:self.detailViewController];

        [self.detailViewController setExamples:examples];
        [self.detailViewController setDetailItem:objects[0]];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please add a client Id to your code."
                                              message:@"Visit http://go.microsoft.com/fwlink/?LinkId=392537 for instructions on getting a Client Id. Please specify your client ID at field ClientId in the ONSCPSCreateExamples.m file and rebuild the application."
                                              delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    /**
    Check if client ID has not yet been entered in ONSCPSCreateExamples
    If yes, alert that a client ID must be inserted in file ONSCPSCreateExamples.m
     */
    if([[ONSCPSCreateExamples getClientId]  isEqual: @"Insert Your Client Id Here"]) {
        [alert show];
    }
}

- (void)createSampleData
{
    if(!objects) {
        objects = @[
                     [[ONSCPSDataItem alloc] initWithTitle:@"Simple page" description:@"Create a simple page using HTML to describe the page content." implementation:@selector(createSimplePage)],
                     [[ONSCPSDataItem alloc] initWithTitle:@"Page with image" description:@"Create a page with some formatted text and an image." implementation:@selector(createPageWithImage)],
                     [[ONSCPSDataItem alloc] initWithTitle:@"Embedded web page" description:@"Create a page with a snapshot of the HTML of a web page on it." implementation: @selector(createPageWithEmbeddedWebPage)],
                     [[ONSCPSDataItem alloc] initWithTitle:@"Public web page" description:@"Create a page with a snapshot of the OneNote.com homepage on it." implementation:@selector(createPageWithUrl)],
                     [[ONSCPSDataItem alloc] initWithTitle:@"Page with file attachment" description:@"Create a page with a file attachment on it." implementation:@selector(createPageWithAttachment)]
                     ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    ONSCPSDataItem *object = objects[indexPath.row];
    cell.textLabel.text = [object title];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        ONSCPSDataItem *object = objects[indexPath.row];
        self.detailViewController.detailItem = object;
        
        // Reset the facade callback to the new controller.
        [examples setDelegate:self.detailViewController];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ONSCPSDataItem *object = objects[indexPath.row];
        if ([[segue destinationViewController] isKindOfClass:([ONSCPSDetailViewController class])])
        {
            // Setup for iPhone, where this is the first sign of detail view
            self.detailViewController = [segue destinationViewController];
            
            examples = [[ONSCPSCreateExamples alloc] initWithDelegate:self.detailViewController];
            
            [self.detailViewController setExamples:examples];
            [self.detailViewController setDetailItem:object];
        }
    }
}

@end
