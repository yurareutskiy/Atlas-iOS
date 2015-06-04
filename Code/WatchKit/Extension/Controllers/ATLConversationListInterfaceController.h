//
//  ATLConversationListInterfaceController
//  Layer Messenger
//
//  Created by Kevin Coleman on 5/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLAvatarItem.h"

@class ATLConversationListInterfaceController;

///---------------------------------------
/// @name Delegate
///---------------------------------------


@protocol ATLConversationListInterfaceControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that an `LYRConversation` was selected from the conversation list.
 @param conversationListInterfaceController The `LYRconversationListInterfaceController` in which the selection occurred.
 @param conversation The `LYRConversation` object that was selected.
 */
- (void)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController didSelectConversation:(LYRConversation *)conversation;

@optional

/**
 @abstract Informs the delegate that an `LYRConversation` was deleted.
 @param conversationListInterfaceController The `LYRconversationListInterfaceController` in which the deletion occurred.
 @param conversation The `LYRConversation` object that was deleted.
 @param deletionMode The `LYRDeletionMode` with which the conversation was deleted.
 */
- (void)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode;

/**
 @abstract Informs the delegate that an attempt to delete an `LYRConversation` failed.
 @param conversationListInterfaceController The `LYRconversationListInterfaceController` in which the deletion attempt occurred.
 @param conversation The `LYRConversation` object that failed deletion.
 @param deletionMode The `LYRDeletionMode` with which the conversation delete attempt was made.
 @param error An `NSError` object describing the deletion failure.
 */
- (void)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error;

@end

///---------------------------------------
/// @name Data Source
///---------------------------------------

@protocol ATLConversationListInterfaceControllerDataSource <NSObject>

/**
 @abstract Asks the data source for a title string to display for a given conversation.
 @param conversationListInterfaceController The `LYRconversationListInterfaceController` in which the string will appear.
 @param conversation The `LYRConversation` object.
 @return The string to be displayed as the title for a given conversation in the conversation list.
 */
- (NSString *)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController titleForConversation:(LYRConversation *)conversation;

@optional

/**
 @abstract Asks the delegate for an avatar item representing a conversation.
 @param conversationListInterfaceController The `LYRconversationListInterfaceController` in which the item's data will appear.
 @param conversation The `LYRConversation` object.
 @return An object conforming to the `ATLAvatarItem` protocol.
 @discussion The data provided by the object conforming to the `ATLAvatarItem` protocol will be displayed in an `LYRAvatarImageView`.
 */
- (id<ATLAvatarItem>)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController avatarItemForConversation:(LYRConversation *)conversation;

/**
 @abstract Asks the data source for the table view cell reuse identifier for a conversation.
 @param conversationListInterfaceController The `ATLConversationListInterfaceController` requesting the string.
 @return A string that will be used to dequeue a cell from the table view.
 @discussion Applications that wish to use prototype cells from a UIStoryboard in the ATLConversationListInterfaceController cannot register their cells programmatically.
 The cell must be given a reuse identifier in the UIStoryboard and that string needs to be passed into the ATLConversationListInterfaceController so it can properly dequeue a
 reuseable cell. If 'nil' is returned, the table view will default to internal values for reuse identifiers.
 */
- (NSString *)reuseIdentifierForconversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController;

/**
 @abstract Asks the data source for a string to display on the delete button for a given deletion mode.
 @param conversationListInterfaceController The `LYRconversationListInterfaceController` in which the button title will appear.
 @param deletionMode The `LYRDeletionMode` for which a button has to be displayed.
 @return The string to be displayed on the delete button for a given deletion mode in the conversation list.
 */
- (NSString *)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController textForButtonWithDeletionMode:(LYRDeletionMode)deletionMode;

/**
 @abstract Asks the data source for a color to apply to the delete button for a given deletion mode.
 @param conversationListInterfaceController The `LYRconversationListInterfaceController` in which the button title will appear.
 @param deletionMode The `LYRDeletionMode` for which a button has to be displayed.
 @return The color to apply on the delete button for a given deletion mode in the conversation list.
 */
- (UIColor *)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController colorForButtonWithDeletionMode:(LYRDeletionMode)deletionMode;

/**
 @abstract Asks the data source for the string to display as the conversation's last sent message.
 @params conversation The conversation for which the last message text should be returned.
 @return A string representing the content of the last message.  If `nil` is returned the controller will fall back to default behavior.
 @discussion This is used when the application uses custom `MIMEType`s and wants to customize how they are displayed.
 */
- (NSString *)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController lastMessageTextForConversation:(LYRConversation *)conversation;

/**
 @abstract Asks the data source to configure the query used to fetch content for the controller if necessary.
 @discussion The `LYRconversationListInterfaceController` uses the following default query:
 
 LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
 query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsIn value:self.layerClient.authenticatedUserID];
 query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
 
 Applications that require advanced query configuration can do so by implementing this data source method.
 
 @param viewController The `ATLConversationViewController` requesting the configuration.
 @param defaultQuery An `LYRQuery` object with the default configuration for the controller.
 @return An `LYRQuery` object with any additional configuration.
 @raises `NSInvalidArgumentException` if an `LYRQuery` object is not returned.
 */
- (LYRQuery *)conversationListInterfaceController:(ATLConversationListInterfaceController *)viewController willLoadWithQuery:(LYRQuery *)defaultQuery;

@end

@interface ATLConversationListInterfaceController : WKInterfaceController

@property (nonatomic) LYRClient *layerClient;

@property (nonatomic, weak) id<ATLConversationListInterfaceControllerDataSource>dataSource;

@property (nonatomic, weak) id<ATLConversationListInterfaceControllerDelegate>delegate;

@property (strong, nonatomic) IBOutlet WKInterfaceTable *conversationTable;

- (void)configureConversationListController;

@end
