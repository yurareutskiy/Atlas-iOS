//
//  ATLInputView.h
//  Atlas
//
//  Created by Kabir Mahal on 4/18/16.
//  Copyright (c) 2016 Layer, Inc. All rights reserved.
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

#import <Foundation/Foundation.h>

/**
 @abstract The `ATLInputView` allows for custom input views to be used within the `ATLConversationViewController`.
 */
@protocol ATLInputView <NSObject>

/**
 @abstract The title that should be used when displaying the input view option when the message input toolbar left accessory button is tapped.
 */
@property (nonatomic, readonly) NSString *atlasAlertActionTitle;

@end
