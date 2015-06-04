//
//  ATLHeaderRow.h
//  Layer Messenger
//
//  Created by Kevin Coleman on 6/2/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h> 
#import "ATLParticipant.h"

@interface ATLHeaderRow : NSObject

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *dateGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *senderGroup;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *senderLabel;

- (void)updateWithParticipant:(id<ATLParticipant>)participant;

@end
