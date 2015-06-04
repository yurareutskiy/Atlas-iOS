//
//  ATLWatchConversationListViewController.m
//  Layer Messenger
//
//  Created by Kevin Coleman on 5/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLConversationListInterfaceController.h"
#import "ATLConversationRow.h"
#import "ATLMessagingUtilities.h"
#import "ATLConstants.h"
#import <LayerKit/LayerKit.h>

static NSDateFormatter *ATLDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    return dateFormatter;
}

@interface ATLConversationListInterfaceController () <ATLConversationListInterfaceControllerDelegate>

@property (nonatomic) LYRQueryController *queryController;

@end

@implementation ATLConversationListInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    self.delegate = self;
    self.layerClient = [context objectForKey:ATLLayerClientKey];
    [self fetchConversations];
}

- (void)fetchConversations
{
    NSError *error;
    LYRQuery *query = ATLConversationListDefaultQueryForAuthenticatedUserID(self.layerClient.authenticatedUserID);
    self.queryController = [self.layerClient queryControllerWithQuery:query];
    BOOL success = [self.queryController execute:&error];
    if (!success) {
        NSLog(@"Failed to execute query with error %@", error);
    }
}

- (void)configureConversationListController
{
    NSUInteger conversationCount = [self.queryController numberOfObjectsInSection:0];
    [self.conversationTable setNumberOfRows:conversationCount withRowType:@"conversationRow"];
    for (NSInteger i = 0; i < conversationCount; i++) {
        ATLConversationRow *row = [self.conversationTable rowControllerAtIndex:i];
        LYRConversation *conversation = [self.queryController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [self configureRow:row forConversation:conversation];
    }
}

- (void)configureRow:(ATLConversationRow *)row forConversation:(LYRConversation *)conversation
{
    NSString *title;
    if ([self.delegate respondsToSelector:@selector(conversationListInterfaceController:titleForConversation:)]) {
        title = [self.dataSource conversationListInterfaceController:self titleForConversation:conversation];
    }
    [row.titleLabel setText:title];
    [row.lastMessageLabel setText:ATLLastMessageTextForMessage(conversation.lastMessage)];
    [row.dateLabel setText:[ATLDateFormatter() stringFromDate:conversation.lastMessage.receivedAt]];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    LYRConversation *conversation = [self.queryController objectAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
    [self.delegate conversationListInterfaceController:self didSelectConversation:conversation];
}
     
- (NSString *)conversationListInterfaceController:(ATLConversationListInterfaceController *)controller titleForConversation:(LYRConversation *)conversation
{
    return @"Test Title";
}

@end



