//
//  ATLUIConversationListTest.m
//  Atlas
//
//  Created by Kevin Coleman on 12/16/14.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>
#import <Atlas/Atlas.h>
#import "ATLTestInterface.h"
#import "LYRClientMock.h"
#import "ATLSampleConversationListViewController.h"

extern NSString *const ATLAvatarImageViewAccessibilityLabel;

@interface ATLConversationListViewController ()

@property (nonatomic) LYRQueryController *queryController;

@end

@interface ATLConversationListViewControllerTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) ATLConversationListViewController *viewController;

@end

@implementation ATLConversationListViewControllerTest

- (void)setUp
{
    [super setUp];
    
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
}

- (void)tearDown
{
    [super tearDown];

    [self.testInterface dismissPresentedViewController];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Messages"];
    [tester waitForAnimationsToFinish];
 
    if (self.viewController) self.viewController = nil;
    [self resetAppearance];
}

- (void)testToVerifyConversationListBaseUI
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self presentViewController:self.viewController];
    
    [tester waitForViewWithAccessibilityLabel:@"Messages"];
    [tester waitForViewWithAccessibilityLabel:@"Edit Button"];
}

- (void)testToVerifyCreatingANewConversationLiveUpdatesConversationList
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:1.0]; // Allow controller to be presented.
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
}

- (void)testToVerifyConversationListDisplaysAllConversationsInLayer
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    [self newConversationWithMockUser:mockUser2 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser3 = [ATLUserMock userWithMockUserName:ATLMockUserNameSteven];
    [self newConversationWithMockUser:mockUser3 lastMessageText:@"Test Message"];
}

- (void)testToVerifyGlobalDeletionButtonFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    
    NSString *message1 = @"Message1";
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:message1];
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:LYRDeletionModeAllParticipants];
}

- (void)testToVerifyLocalDeletionButtonFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:LYRDeletionModeMyDevices];
}

- (void)testToVerifyEditingModeAndMultipleConversationDeletionFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    LYRConversationMock *conversation2 = [self newConversationWithMockUser:mockUser2 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser3 = [ATLUserMock userWithMockUserName:ATLMockUserNameSteven];
    LYRConversationMock *conversation3 = [self newConversationWithMockUser:mockUser3 lastMessageText:@"Test Message"];
    
    [tester tapViewWithAccessibilityLabel:@"Edit"];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", mockUser1.fullName]];
    [self deleteConversation:conversation1 deletionMode:LYRDeletionModeMyDevices];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", mockUser2.fullName]];
    [self deleteConversation:conversation2 deletionMode:LYRDeletionModeMyDevices];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", mockUser3.fullName]];
    [self deleteConversation:conversation3 deletionMode:LYRDeletionModeMyDevices];
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    NSOrderedSet *conversations = [self.testInterface.layerClient executeQuery:query error:&error];
    expect(error).to.beNil;
    expect(conversations).to.beNil;
}

- (void)testToVerifyDisablingEditModeDoesNotAllowUserToDeleteConversations
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setAllowsEditing:NO];
    [self presentViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[NSString stringWithFormat:@"Global"]];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[NSString stringWithFormat:@"Local"]];
}

- (void)testToVerifyColorAndFontChangeFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    
    UIFont *testFont = [UIFont systemFontOfSize:20];
    UIColor *testColor = [UIColor redColor];
    
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelFont:testFont];
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelColor:testColor];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    NSString *conversationLabel = [self.testInterface conversationLabelForConversation:conversation1];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    expect(cell.conversationTitleLabelFont).to.equal(testFont);
    expect(cell.conversationTitleLabelColor).to.equal(testColor);
}

- (void)testToVerifyCustomRowHeightFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setRowHeight:100];
    [self presentViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    NSString *conversationLabel = [self.testInterface conversationLabelForConversation:conversation1];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    expect(cell.frame.size.height).to.equal(100);
}

-(void)testToVerifyCustomCellClassFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setCellClass:[ATLTestConversationCell class]];
    [self presentViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    NSString *conversationLabel = [self.testInterface conversationLabelForConversation:conversation1];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    expect([cell class]).to.equal([ATLTestConversationCell class]);
    expect([cell class]).toNot.equal([ATLConversationTableViewCell class]);
}

//Verify search bar does show up on screen for default `shouldDisplaySearchController` value `YES`.
- (void)testToVerifyDefaultShouldDisplaySearchControllerFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    [tester waitForViewWithAccessibilityLabel:@"Search Bar"];
}

//Verify search bar does not show up on screen if property set to `NO`.
- (void)testToVerifyShouldDisplaySearchControllerFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setShouldDisplaySearchController:NO];
    [self presentViewController:self.viewController];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Search Bar"];
}

//Verify that attempting to provide a cell class that does not conform to ATLConversationPresenting results in a runtime exception.
- (void)testToVerifyCustomCellClassNotConformingToProtocolRaisesException
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    expect(^{ [self.viewController setCellClass:[UITableViewCell class]]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:1.0]; // Allow controller to be presented.
    expect(^{ [self.viewController setCellClass:[ATLTestConversationCell class]]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellHeighAfterViewLoadRaiseException
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:1.0]; // Allow controller to be presented.
    expect(^{ [self.viewController setRowHeight:40]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingEditingSettingAfterViewLoadRaiseException
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:1.0]; // Allow controller to be presented.
    expect(^{ [self.viewController setAllowsEditing:YES]; }).to.raise(NSInternalInconsistencyException);
}

#pragma mark - ATLConversationListViewControllerDataSource

- (void)testToVerifyConversationListViewControllerDataSource
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.displaysAvatarItem = YES;
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    
    LYRConversation *conversation;
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        void *tempConversation;
        [invocation getArgument:&tempConversation atIndex:3];
        LYRConversation *conversation = (__bridge LYRConversation *)tempConversation;
        expect(conversation).to.equal(conversation);
        
        NSString *conversationTitle = mockUser1.fullName;
        [invocation setReturnValue:&conversationTitle];
    }] conversationListViewController:[OCMArg any] titleForConversation:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        void *tempConversation;
        [invocation getArgument:&tempConversation atIndex:3];
        LYRConversation *conversation = (__bridge LYRConversation *)tempConversation;
        expect(conversation).to.equal(conversation);
    }] conversationListViewController:[OCMArg any] avatarItemForConversation:[OCMArg any]];
    
    conversation = (LYRConversation *)[self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    [delegateMock verify];
}

#pragma mark - ATLConversationListViewControllerDelegate

- (void)testToVerifyDelegateIsNotifiedOfConversationSelection
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        void *tempConversation;
        [invocation getArgument:&tempConversation atIndex:3];
        LYRConversation *conversation = (__bridge LYRConversation *)tempConversation;
        expect(conversation).to.equal(conversation);
    }] conversationListViewController:[OCMArg any] didSelectConversation:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1]];
    [delegateMock verify];
}

- (void)testToVerifyDelegateIsNotifiedOfGlobalConversationDeletion
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    LYRDeletionMode deletionMode = LYRDeletionModeAllParticipants;
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        void *tempConversation;
        [invocation getArgument:&tempConversation atIndex:3];
        LYRConversation *conversation = (__bridge LYRConversation *)tempConversation;
        expect(conversation).to.equal(conversation);
        
        void *tempMode;
        [invocation getArgument:&tempMode atIndex:4];
        LYRDeletionMode mode = (LYRDeletionMode)tempMode;
        expect(mode).to.equal(deletionMode);
    }] conversationListViewController:[OCMArg any] didDeleteConversation:[OCMArg any] deletionMode:deletionMode];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:deletionMode];
    [delegateMock verify];
}

- (void)testToVerifyDelegateIsNotifiedOfLocalConversationDeletion
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    LYRDeletionMode deletionMode = LYRDeletionModeMyDevices;
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        void *tempConversation;
        [invocation getArgument:&tempConversation atIndex:3];
        LYRConversation *conversation = (__bridge LYRConversation *)tempConversation;
        expect(conversation).to.equal(conversation);
        
        void *tempMode;
        [invocation getArgument:&tempMode atIndex:4];
        LYRDeletionMode mode = (LYRDeletionMode)tempMode;
        expect(mode).to.equal(deletionMode);
    }] conversationListViewController:[OCMArg any] didDeleteConversation:[OCMArg any] deletionMode:deletionMode];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:deletionMode];
    [delegateMock verify];
}

- (void)testToVerifyDelegateIsNotifiedOfSearch
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self presentViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    __block NSString *searchText = @"T";
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);

        void *tempText;
        [invocation getArgument:&tempText atIndex:3];
        NSString *searchText = (__bridge NSString *)tempText;
        expect(searchText).to.equal(searchText);
    }] conversationListViewController:[OCMArg any] didSearchForText:searchText completion:[OCMArg any]];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1]  inDirection:KIFSwipeDirectionDown];
    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:searchText intoViewWithAccessibilityLabel:@"Search Bar"];
    [delegateMock verify];
}

- (void)testToVerifyCustomDeletionColorAndText
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self presentViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    [tester waitForAnimationsToFinish];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        NSString *deletionTitle = @"Test";
        [invocation setReturnValue:&deletionTitle];
    }] conversationListViewController:[OCMArg any] textForButtonWithDeletionMode:LYRDeletionModeAllParticipants];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        UIColor *green = [UIColor greenColor];
        [invocation setReturnValue:&green];
    }] conversationListViewController:[OCMArg any] colorForButtonWithDeletionMode:LYRDeletionModeAllParticipants];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1]  inDirection:KIFSwipeDirectionLeft];
    [delegateMock verify];
    
    UIView *deleteButton = [tester waitForViewWithAccessibilityLabel:@"Test"];
    expect(deleteButton.backgroundColor).to.equal([UIColor greenColor]);
}

- (void)testToVerifyDefaultQueryConfigurationDataSourceMethod
{
    self.viewController = [ATLConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        void *tempQuery;
        [invocation getArgument:&tempQuery atIndex:3];
        LYRQuery *query = (__bridge LYRQuery *)tempQuery;
        expect(query).toNot.beNil();
        
        [invocation setReturnValue:&query];
    }] conversationListViewController:[OCMArg any] willLoadWithQuery:[OCMArg any]];
    
    [self presentViewController:self.viewController];
    [delegateMock verifyWithDelay:1];
}

- (void)testToVerifyQueryConfigurationTakesEffect
{
    self.viewController = [ATLConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    __block NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLConversationListViewController *controller = (__bridge ATLConversationListViewController *)tempController;
        expect(controller).to.equal(self.viewController);
        
        void *tempQuery;
        [invocation getArgument:&tempQuery atIndex:3];
        LYRQuery *query = (__bridge LYRQuery *)tempQuery;
        expect(query).toNot.beNil();
        
        query.sortDescriptors = @[sortDescriptor];
        [invocation setReturnValue:&query];
    }] conversationListViewController:[OCMArg any] willLoadWithQuery:[OCMArg any]];
    
    [self presentViewController:self.viewController];
    [delegateMock verifyWithDelay:2];
    
    expect(self.viewController.queryController.query.sortDescriptors).will.contain(sortDescriptor);
}

- (void)testToVerifyAvatarImageURLLoad
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.displaysAvatarItem = YES;
    [self presentViewController:self.viewController];
    
    [self newConversationWithMockUser:[ATLUserMock userWithMockUserName:ATLMockUserNameAmar] lastMessageText:@"Hi"];
    
    ATLAvatarImageView *imageView = (ATLAvatarImageView *)[tester waitForViewWithAccessibilityLabel:ATLAvatarImageViewAccessibilityLabel];
    expect(imageView.image).will.beTruthy;
}

- (LYRConversationMock *)newConversationWithMockUser:(ATLUserMock *)mockUser lastMessageText:(NSString *)lastMessageText
{
    LYRConversationMock *conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser.participantIdentifier] lastMessageText:lastMessageText];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation]];
    return conversation;
}

- (void)deleteConversation:(LYRConversationMock *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    switch (deletionMode) {
        case LYRDeletionModeAllParticipants:
            [tester waitForViewWithAccessibilityLabel:@"Everyone"];
            [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Everyone"]];
            [tester waitForAbsenceOfViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation]];
            break;
        case LYRDeletionModeMyDevices:
            [tester waitForViewWithAccessibilityLabel:@"My Devices"];
            [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"My Devices"]];
            [tester waitForAbsenceOfViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation]];
            break;
        default:
            break;
    }
}

- (void)presentViewController:(UITableViewController *)controller
{
    [self.testInterface presentViewController:controller];
    [tester waitForViewWithAccessibilityLabel:@"Messages"];
    [tester waitForAnimationsToFinish];
}

- (void)resetAppearance
{
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelFont:[UIFont systemFontOfSize:14]];
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelColor:[UIColor blackColor]];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelFont:[UIFont systemFontOfSize:12]];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelColor:[UIColor grayColor]];
    [[ATLConversationTableViewCell appearance] setDateLabelFont:[UIFont systemFontOfSize:12]];
    [[ATLConversationTableViewCell appearance] setDateLabelColor:[UIColor grayColor]];
    [[ATLConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:[UIColor cyanColor]];
    [[ATLConversationTableViewCell appearance] setCellBackgroundColor:[UIColor whiteColor]];
    
}

@end