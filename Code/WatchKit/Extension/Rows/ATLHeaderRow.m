//
//  ATLHeaderRow.m
//  Layer Messenger
//
//  Created by Kevin Coleman on 6/2/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLHeaderRow.h"

@implementation ATLHeaderRow

- (void)updateWithParticipant:(id<ATLParticipant>)participant
{
    [self.senderLabel setText:[participant fullName]];
}

@end
