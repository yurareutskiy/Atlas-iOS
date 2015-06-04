    //
//  ATLWatchConversationViewController.m
//  Layer Messenger
//
//  Created by Kevin Coleman on 5/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLConversationInterfaceController.h"
#import <LayerKit/LayerKit.h>
#import "ATLMessageRow.h"
#import "ATLMessagingUtilities.h"
#import "ATLConversationDataSource.h"
#import "ATLConstants.h"

#import "ATLIncomingRow.h"
#import "ATLOutgoingRow.h"
#import "ATLHeaderRow.h"
#import "ATLFooterRow.h"

#import "ATLMessagingUtilities.h"

@interface ATLConversationInterfaceController () <LYRProgressDelegate, LYRQueryControllerDelegate>

@property (nonatomic) ATLConversationDataSource *conversationQueryController;
@property (nonatomic) NSMutableArray *insertedIndexes;

@end

@implementation ATLConversationInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    self.insertedIndexes = [NSMutableArray new];
    self.layerClient = [context objectForKey:ATLLayerClientKey];
    self.conversation = [context objectForKey:ATLLayerConversationKey];
}

- (void)willActivate
{
    [super willActivate];
    NSUInteger lastIndex = [self.messageTable numberOfRows] - 1;
    [self.messageTable scrollToRowAtIndex:lastIndex];
}

- (void)configureConversationViewController
{
    LYRQuery *query = ATLMessageListDefaultQueryForConversation(self.conversation);
    self.conversationQueryController = [ATLConversationDataSource dataSourceWithLayerClient:self.layerClient query:query];
    self.conversationQueryController.dateDisplayTimeInterval = 60*60;
    self.conversationQueryController.queryController.delegate = self;
    
    NSUInteger messageCount = [self.conversationQueryController.queryController numberOfObjectsInSection:0];
    [self calculateRowsForMessageCount:messageCount];
    [self configureRowContent];
}

- (void)calculateRowsForMessageCount:(NSUInteger)messageCount
{
    NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity:messageCount];
    for (NSUInteger i = 0; i < messageCount; i++) {
        LYRMessage *message = [self.conversationQueryController messageAtCollectionViewSection:i];
        if ([message.sender.userID isEqualToString:self.layerClient.authenticatedUserID]) {
            [rows addObject:@"outgoingRow"];
        } else {
            [rows addObject:@"incomingRow"];
        }
    }
    [self.messageTable setRowTypes:rows];
}

- (void)configureRowContent
{
    NSUInteger rowCount = self.messageTable.numberOfRows;
    for (NSUInteger i = 0; i < rowCount; i++) {
        [self configureRowAtIndex:i];
    }
}

- (void)configureRowAtIndex:(NSUInteger)index
{
    LYRMessage *message = [self.conversationQueryController messageAtCollectionViewSection:index];
    ATLMessageRow *row = [self.messageTable rowControllerAtIndex:index];
    [row updateWithMessage:message];
    
    if ([self.conversationQueryController shouldDisplayDateLabelForSection:index]) {
        NSAttributedString *dateString =  [self attributedStringForMessageDate:message];
        [row.dateLabel setAttributedText:dateString];
    } else {
        [row.dateLabelGroup setHidden:YES];
    }
    
    if ([self.conversationQueryController shouldDisplaySenderLabelForSection:index]) {
        id<ATLParticipant> sender = [self participantForIdentifier:message.sender.userID];
        [row.senderNameLabel setText:sender.fullName];
    } else {
        [row.senderNameGroup setHidden:YES];
    }
    
    if ([self.conversationQueryController shouldDisplayReadReceiptForSection:index]) {
        NSAttributedString *recipientStatusString = [self attributedStringForRecipientStatusOfMessage:message];
        [row.recipientStatusLabel setAttributedText:recipientStatusString];
    } else {
        [row.footerGroup setHidden:YES];
    }
}

#pragma mark - Message Sending

- (IBAction)replyButtonTapped:(id)sender
{
    [self presentTextInputControllerWithSuggestions:@[@"Taste", @"Taste Test", @"Taste Case",@"A Taste for you", @"Gift", @"Pac o'clock", @"Ride or Die", @"Go Seahawks", @"UCLA > USC", @"Expo Growth > Log Growth"] allowedInputMode:WKTextInputModeAllowAnimatedEmoji completion:^(NSArray *results) {
        NSString *messageText = results[0];
        ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithText:messageText];
        NSOrderedSet *messages = [self messagesForMediaAttachments:@[mediaAttachment]];
        for (LYRMessage *message in messages) {
            [self sendMessage:message];
        }
    }];
}

- (NSOrderedSet *)messagesForMediaAttachments:(NSArray *)mediaAttachments
{
    NSOrderedSet *messages;
    if ([self.delegate respondsToSelector:@selector(conversationInterfaceController:messagesForMediaAttachments:)]) {
        messages = [self.delegate conversationInterfaceController:self messagesForMediaAttachments:mediaAttachments];
        // If delegate returns an empty set, don't send any messages.
        if (messages && !messages.count) return nil;
    }
    // If delegate returns nil, we fall back to default behavior.
    if (!messages) {
        messages = [self defaultMessagesForMediaAttachments:mediaAttachments];
    }
    return messages;
}

- (NSOrderedSet *)defaultMessagesForMediaAttachments:(NSArray *)mediaAttachments
{
    NSMutableOrderedSet *messages = [NSMutableOrderedSet new];
    for (ATLMediaAttachment *attachment in mediaAttachments){
        NSArray *messageParts = ATLMessagePartsWithMediaAttachment(attachment);
        NSString *pushText;
        if ([attachment.mediaMIMEType isEqualToString:ATLMIMETypeTextPlain]) {
            pushText = attachment.textRepresentation;
        } else {
            NSString *senderName = [[self participantForIdentifier:self.layerClient.authenticatedUserID] fullName];
            pushText = ATLPushTextForMessage(senderName, attachment.mediaMIMEType);
        }
        LYRMessage *message = ATLMessageForMessageParameters(self.layerClient, messageParts, pushText);
        if (message) {
            [messages addObject:message];
        }
    }
    return messages;
}

- (void)sendMessage:(LYRMessage *)message
{
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        [self notifyDelegateOfMessageSend:message];
    } else {
        [self notifyDelegateOfMessageSendFailure:message error:error];
    }
}
#pragma mark - Delegate

- (void)notifyDelegateOfMessageSend:(LYRMessage *)message
{
    if ([self.delegate respondsToSelector:@selector(conversationInterfaceController:didSendMessage:)]) {
        [self.delegate conversationInterfaceController:self didSendMessage:message];
    }
}

- (void)notifyDelegateOfMessageSendFailure:(LYRMessage *)message error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(conversationInterfaceController:didFailSendingMessage:error:)]) {
        [self.delegate conversationInterfaceController:self didFailSendingMessage:message error:error];
    }
}

- (void)notifyDelegateOfMessageSelection:(LYRMessage *)message
{
    if ([self.delegate respondsToSelector:@selector(conversationInterfaceController:didSelectMessage:)]) {
        [self.delegate conversationInterfaceController:self didSelectMessage:message];
    }
}

#pragma mark - Data Source 

- (id<ATLParticipant>)participantForIdentifier:(NSString *)identifier
{
    if ([self.dataSource respondsToSelector:@selector(conversationInterfaceController:participantForIdentifier:)]) {
        return [self.dataSource conversationInterfaceController:self participantForIdentifier:identifier];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ATLConversationInterfaceControllerDelegate must return a participant for an identifier" userInfo:nil];
    }
    return nil;
}

- (NSAttributedString *)attributedStringForMessageDate:(LYRMessage *)message
{
    NSAttributedString *dateString;
    if ([self.dataSource respondsToSelector:@selector(conversationInterfaceController:attributedStringForDisplayOfDate:)]) {
        NSDate *date = message.receivedAt ?: [NSDate date];
        dateString = [self.dataSource conversationInterfaceController:self attributedStringForDisplayOfDate:date];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ATLConversationInterfaceControllerDataSource must return an attributed string for Date" userInfo:nil];
    }
    NSAssert([dateString isKindOfClass:[NSAttributedString class]], @"Date string must be an attributed string");
    return dateString;
}

- (NSAttributedString *)attributedStringForRecipientStatusOfMessage:(LYRMessage *)message
{
    NSAttributedString *recipientStatusString;
    if ([self.dataSource respondsToSelector:@selector(conversationInterfaceController:attributedStringForDisplayOfRecipientStatus:)]) {
        recipientStatusString = [self.dataSource conversationInterfaceController:self attributedStringForDisplayOfRecipientStatus:message.recipientStatusByUserID];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ATLConversationInterfaceControllerDataSource must return an attributed string for recipient status" userInfo:nil];
    }
    NSAssert([recipientStatusString isKindOfClass:[NSAttributedString class]], @"Recipient String must be an attributed string");
    return recipientStatusString;
}

- (void)progressDidChange:(LYRProgress *)progress
{
    NSLog(@"progress");
}

#pragma mark - Query Controller Delegate

- (void)queryController:(LYRQueryController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(LYRQueryControllerChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableArray *updatedIndexes = [NSMutableArray new];
    switch (type) {
        case LYRQueryControllerChangeTypeInsert:
            if ([object isKindOfClass:[LYRMessage class]]) {
                LYRMessage *message = object;
                if ([message.sender.userID isEqualToString:self.layerClient.authenticatedUserID]) {
                    [self.messageTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowType:@"outgoingRow"];
                } else {
                    [self.messageTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowType:@"incomingRow"];
                }
                [self configureRowAtIndex:newIndexPath.row - 1];
                [self configureRowAtIndex:newIndexPath.row];
            }
            break;
        case LYRQueryControllerChangeTypeUpdate:
            [updatedIndexes addObject:indexPath];
            break;
        case LYRQueryControllerChangeTypeMove:
            
            break;
        case LYRQueryControllerChangeTypeDelete:
            [self.messageTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]];
            break;
        default:
            break;
    }
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    NSUInteger lastIndex = [self.messageTable numberOfRows] - 1;
    [self.messageTable scrollToRowAtIndex:lastIndex];
}

@end



