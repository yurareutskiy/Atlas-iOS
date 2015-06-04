//
//  ATLFooterRow.h
//  Layer Messenger
//
//  Created by Kevin Coleman on 6/2/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h> 

@interface ATLFooterRow : NSObject

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *recipientStatusGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *recipientStatusLabel;

@end
