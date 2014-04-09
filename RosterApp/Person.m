//
//  Person.m
//  RosterApp
//
//  Created by Reed Sweeney on 4/7/14.
//  Copyright (c) 2014 Reed Sweeney. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

@end