//
//  DataController.h
//  RosterApp
//
//  Created by Reed Sweeney on 4/9/14.
//  Copyright (c) 2014 Reed Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataController : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *studentRoster;
@property (nonatomic, strong) NSMutableArray *teacherRoster;

-(instancetype)initWithTeachersAndStudents;

-(void)save;
+(DataController *)sharedData;

@end
