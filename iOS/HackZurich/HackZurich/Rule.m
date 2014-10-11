//
//  Rule.m
//  HackZurich
//
//  Created by Patrick Amrein on 11/10/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

#import "Rule.h"

@implementation Rule

-(NSString<Ignore>*)title {
    if (self.type == RuleTypeSubstring) {
        return self.text;
    }
    
    return [NSString stringWithFormat:@"#%@", self.text];
}

@end
