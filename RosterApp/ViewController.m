//
//  ViewController.m
//  RosterApp
//
//  Created by Reed Sweeney on 4/7/14.
//  Copyright (c) 2014 Reed Sweeney. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "PersonTableViewCell.h"
#import "DataController.h"

@interface ViewController () <UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DataController *myDataController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myDataController = [[DataController alloc] initWithTeachersAndStudents];
    
    self.tableView.dataSource = self.myDataController;
    self.tableView.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PersonViewController *personVC = segue.destinationViewController;
    NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
    Person *myPerson;
    
    if (myIndexPath.section == 0) {
       myPerson = [self.myDataController.teacherRoster objectAtIndex:myIndexPath.row];
        personVC.title = @"Teacher";
    }
    else {
       myPerson = [self.myDataController.studentRoster objectAtIndex:myIndexPath.row];
        personVC.title = @"Student";
    }
    
    personVC.seletectedPerson = myPerson;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end

