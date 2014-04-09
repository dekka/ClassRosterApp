//
//  Person.h
//  RosterApp
//
//  Created by Reed Sweeney on 4/7/14.
//  Copyright (c) 2014 Reed Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCoding>

@property (nonatomic, strong) NSString *firstName;

@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) NSString *fullName;

@property (nonatomic, strong) UIImage *avatar;

@end
