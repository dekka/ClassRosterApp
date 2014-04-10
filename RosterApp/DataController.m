//
//  DataController.m
//  RosterApp
//
//  Created by Reed Sweeney on 4/9/14.
//  Copyright (c) 2014 Reed Sweeney. All rights reserved.
//

#import "DataController.h"
#import "PersonTableViewCell.h"
#import "Person.h"

@implementation DataController

+(DataController *)sharedData {
    static dispatch_once_t pred;
    static DataController *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[DataController alloc] initWithTeachersAndStudents];
    });
    return shared;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.teacherRoster.count;
    }
    else {
        return self.studentRoster.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Teachers";
    }
    else {
        return @"Students";
    }
}

- (PersonTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Person *myPerson;
    
    if (indexPath.section == 0) {
        myPerson = [self.teacherRoster objectAtIndex:indexPath.row];
    }
    else {
        myPerson = [self.studentRoster objectAtIndex:indexPath.row];
    }
    cell.cellLabel.text = myPerson.firstName;
    
    cell.cellImageView.image = myPerson.avatar;
    
    cell.cellContentView.backgroundColor = myPerson.personColor;
    
    return cell;
}

-(instancetype)initWithTeachersAndStudents
{
    self = [super init];

    NSString *teachersPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Teachers.plist" ];
    NSString *studentsPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Students.plist" ];

    if ([[NSFileManager defaultManager] fileExistsAtPath:teachersPath] && [[NSFileManager defaultManager] fileExistsAtPath:studentsPath])
    {
        self.teacherRoster = [NSKeyedUnarchiver unarchiveObjectWithFile:teachersPath];
        self.studentRoster = [NSKeyedUnarchiver unarchiveObjectWithFile:studentsPath];
        NSLog(@"Plist Files Exist");
        
    } else {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"People" ofType:@"plist"];
        NSDictionary *peopleDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSArray *tempTeacherRoster = [peopleDictionary objectForKey:@"Teachers"];
        NSArray *tempStudentRoster = [peopleDictionary objectForKey:@"Students"];
        
        self.teacherRoster = [[NSMutableArray alloc] init];
        self.studentRoster = [[NSMutableArray alloc] init];
        
        for (NSDictionary *teacherDictionary in tempTeacherRoster) {
            Person *newPerson = [[Person alloc] init];
            newPerson.firstName = [teacherDictionary objectForKey:@"firstName"];
            newPerson.lastName = [teacherDictionary objectForKey:@"lastName"];
            [self.teacherRoster addObject:newPerson];
        }
        
        for (NSDictionary *studentDictionary in tempStudentRoster) {
            Person *newPerson = [[Person alloc] init];
            newPerson.firstName = [studentDictionary objectForKey:@"firstName"];
            newPerson.lastName = [studentDictionary objectForKey:@"lastName"];
            [self.studentRoster addObject:newPerson];
        }
        
        [NSKeyedArchiver archiveRootObject:self.teacherRoster toFile:teachersPath];
        [NSKeyedArchiver archiveRootObject:self.studentRoster toFile:studentsPath];
    }
    
    return self;
}

-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

-(BOOL)checkForPlistFileInDocs:(NSString *)fileName
{
    NSError *error;
    
    NSFileManager *myManager = [NSFileManager defaultManager];
    
    NSString *pathForPlistInBundle = [[NSBundle mainBundle] pathForResource:@"People" ofType:@"plist"];
    
    NSString *pathForPlistInDocs = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    
    return [myManager fileExistsAtPath:pathForPlistInDocs];
    
    
    [myManager copyItemAtPath:pathForPlistInBundle toPath:pathForPlistInDocs error:&error];
    
    
    return NO;
}

-(void)save
{
    NSString *teacherPlistPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Teachers.plist"];
    NSString *studentPlistPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Students.plist"];

    [NSKeyedArchiver archiveRootObject:self.teacherRoster toFile:teacherPlistPath];
    [NSKeyedArchiver archiveRootObject:self.studentRoster toFile:studentPlistPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Deleting Cell At Row: %d", indexPath.row);
        [self.studentRoster removeObject:[self.studentRoster objectAtIndex:indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self save];
    }
    
}


@end










