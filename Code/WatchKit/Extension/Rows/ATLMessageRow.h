//
//  ATLMessageRow.h
//  Layer Messenger
//
//  Created by Kevin Coleman on 5/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h> 
#import <LayerKit/LayerKit.h>

@interface ATLMessageRow : NSObject

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *labelGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *imageGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *mapGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *dateLabelGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *senderNameGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *headerGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *footerGroup;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *label;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *image;
@property (strong, nonatomic) IBOutlet WKInterfaceMap *map;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *senderNameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *recipientStatusLabel;

- (void)updateWithMessage:(LYRMessage *)message;

@end
