//
//  MasterViewController.m
//  FacebookD8-PhotoLinkr
//
//  Created by Ivan Andriollo on 17/06/2014.
//  Copyright (c) 2014 PL. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Photo.h"
#import "CloudDatabaseManager.h"

@interface MasterViewController () <UIImagePickerControllerDelegate>
            
@property NSMutableArray *objects;

@end

@implementation MasterViewController
            
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [self.navigationController presentViewController:pickerController
                                            animated:YES
                                          completion:nil];
    
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)refreshObjects {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"YES"];
    CKQuery* queryPhotos = [[CKQuery alloc] initWithRecordType:@"Photo" predicate:predicate];
    NSSortDescriptor* timeSortOrder = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    queryPhotos.sortDescriptors = @[ timeSortOrder ];
    
    CKQueryOperation* queryOperation = [[CKQueryOperation alloc] initWithQuery:queryPhotos];
    __block NSMutableArray* returnResults = [[NSMutableArray alloc] init];
    queryOperation.recordFetchedBlock = ^(CKRecord* record) {
        [returnResults addObject:record];
    };
    queryOperation.queryCompletionBlock = ^(CKQueryCursor* cursor, NSError* error) {
        if (!error && returnResults.count > 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.objects removeAllObjects];
                [self.objects addObjectsFromArray:returnResults];
                [self.tableView reloadData];
            });
        }
    };
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    Photo *photo = [[Photo alloc] initWithImage:image username:@"test_user"];
    [[CloudDatabaseManager sharedInstance] submitPhoto:photo withCompletion:nil];
}

@end
