//
//  ATLConversationRow.h
//  Layer Messenger
//
//  Created by Kevin Coleman on 5/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface ATLConversationRow : NSObject

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *lastMessageLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;

@end
