//
//  ALTAddressBarViewControllerTest.m
//  Atlas
//
//  Created by Kevin Coleman on 2/21/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ATLSampleConversationViewController.h"
#import "ATLTestInterface.h"

@interface ALTAddressBarControllerTest : XCTestCase

@property (nonatomic) ATLSampleConversationViewController *viewController;
@property (nonatomic) ATLTestInterface *testInterface;

@end

@implementation ALTAddressBarControllerTest

extern NSString *const ATLAddressBarAccessibilityLabel;
extern NSString *const ATLAddressBarViewAccessibilityLabel;
extern NSString *const ATLAddressBarTextViewAccesssibilityLabel;
extern NSString *const ATLMessageInputToolbarAccessibilityLabel;
extern NSString *const ATLAddContactsButtonAccessibilityLabel;

- (void)setUp
{
    [super setUp];
    
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    
    self.viewController = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.displaysAddressBar = YES;
    [self setRootViewController:self.viewController];
}

- (void)tearDown
{
    [self.testInterface dismissPresentedViewController];
    [tester waitForAnimationsToFinish];
    [super tearDown];
}

- (void)testToVerifyAddressBarUI
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarViewAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarTextViewAccesssibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLAddContactsButtonAccessibilityLabel];
}

#pragma mark - ATLAddressBarControllerDelegate
//- (void)addressBarViewControllerDidBeginSearching:(ATLAddressBarViewController *)addressBarViewController;
- (void)testToVerifyAddressBarDelegateOnSearchBegins
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;

    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLAddressBarViewController *controller = (__bridge ATLAddressBarViewController *)tempController;
        expect(controller).to.beKindOf([ATLAddressBarViewController class]);
    }] addressBarViewControllerDidBeginSearching:[OCMArg any]];
    
    [tester enterText:@"Test" intoViewWithAccessibilityLabel:ATLAddressBarTextViewAccesssibilityLabel];
    [delegateMock verify];
}

//- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didSelectParticipant:(id<ATLParticipant>)participant;
- (void)testToVerifyAddressBarDelegateOnParticipantSelection
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLAddressBarViewController *controller = (__bridge ATLAddressBarViewController *)tempController;
        expect(controller).to.beKindOf([ATLAddressBarViewController class]);
    }] addressBarViewController:[OCMArg any] didSelectParticipant:[OCMArg any]];
    
    [addressBar selectParticipant:[ATLUserMock userWithMockUserName:ATLMockUserNameAmar]];
    [delegateMock verify];
}

//- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didRemoveParticipant:(id<ATLParticipant>)participant;
- (void)testToVerifyAddressBarDelegateOnParticipantRemoval
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLAddressBarViewController *controller = (__bridge ATLAddressBarViewController *)tempController;
        expect(controller).to.beKindOf([ATLAddressBarViewController class]);
    }] addressBarViewController:[OCMArg any] didRemoveParticipant:[OCMArg any]];
    
    [addressBar selectParticipant:[ATLUserMock userWithMockUserName:ATLMockUserNameAmar]];
    [addressBar setSelectedParticipants:[NSOrderedSet new]];
    [delegateMock verify];
}

//- (void)addressBarViewControllerDidEndSearching:(ATLAddressBarViewController *)addressBarViewController;
- (void)testToVerifyAddressBarDelegateOnWhenSearchEnds
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLAddressBarViewController *controller = (__bridge ATLAddressBarViewController *)tempController;
        expect(controller).to.beKindOf([ATLAddressBarViewController class]);
    }] addressBarViewControllerDidEndSearching:[OCMArg any]];
    
    [tester enterText:@"A" intoViewWithAccessibilityLabel:ATLAddressBarTextViewAccesssibilityLabel];
    NSOrderedSet *participants = [NSOrderedSet orderedSetWithObject:[ATLUserMock userWithMockUserName:ATLMockUserNameKlemen]];
    [addressBar setSelectedParticipants:participants];
    [delegateMock verify];
}

//- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton;
- (void)testToVerifyAddressBarDelegateOnAddContactButtonTap
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLAddressBarViewController *controller = (__bridge ATLAddressBarViewController *)tempController;
        expect(controller).to.beKindOf([ATLAddressBarViewController class]);
    }] addressBarViewController:[OCMArg any] didTapAddContactsButton:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:ATLAddContactsButtonAccessibilityLabel];
    [delegateMock verify];
}

//- (void)addressBarViewControllerDidSelectWhileDisabled:(ATLAddressBarViewController *)addressBarViewController;
- (void)testToVerifyAddressBarDelegateFunctionalityOnDisabledTap
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLAddressBarViewController *controller = (__bridge ATLAddressBarViewController *)tempController;
        expect(controller).to.beKindOf([ATLAddressBarViewController class]);
    }] addressBarViewControllerDidSelectWhileDisabled:[OCMArg any]];
    
    [addressBar disable];
    [tester tapViewWithAccessibilityLabel:ATLAddressBarViewAccessibilityLabel];
    [delegateMock verify];
}

//- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *participants))completion;
- (void)testToVerifyAddressBarFunctionaltyOnSearch
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        void *tempController;
        [invocation getArgument:&tempController atIndex:2];
        ATLAddressBarViewController *controller = (__bridge ATLAddressBarViewController *)tempController;
        expect(controller).to.beKindOf([ATLAddressBarViewController class]);
    }] addressBarViewController:[OCMArg any] searchForParticipantsMatchingText:[OCMArg any] completion:[OCMArg any]];

    [tester enterText:@"Search" intoViewWithAccessibilityLabel:ATLAddressBarTextViewAccesssibilityLabel];
    [delegateMock verify];
}

- (void)testToVerifySelectingParticipant
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    id delegateMock = OCMProtocolMock(@protocol(ATLAddressBarViewControllerDelegate));
    addressBar.delegate = delegateMock;
    
    ATLUserMock *mock = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    [addressBar selectParticipant:mock];
    expect(addressBar.addressBarView.addressBarTextView.text).to.contain(mock.fullName);
}

- (void)testToVerifyDisableFunctionality
{
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    ATLAddressBarViewController *addressBar = self.viewController.addressBarController;
    [addressBar disable];
    expect(addressBar.isDisabled).to.beTruthy;
}

- (void)setRootViewController:(UIViewController *)controller
{
    [self.testInterface presentViewController:controller];
    [tester waitForTimeInterval:1];
}


@end
