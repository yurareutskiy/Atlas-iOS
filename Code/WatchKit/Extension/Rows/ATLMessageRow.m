//
//  ATLMessageRow.m
//  Layer Messenger
//
//  Created by Kevin Coleman on 5/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLMessageRow.h"
#import "ATLMessagingUtilities.h"

@interface ATLMessageRow ()

@property (nonatomic) LYRMessage *message;

@end

@implementation ATLMessageRow

- (void)updateWithMessage:(LYRMessage *)message
{
    self.message = message;
    
    LYRMessagePart *messagePart = message.parts[0];
    if ([messagePart.MIMEType isEqualToString:ATLMIMETypeTextPlain]) {
        [self configureBubbleViewForTextContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageJPEG]) {
        [self configureBubbleViewForImageContent];
    }else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImagePNG]) {
        [self configureBubbleViewForImageContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageGIF]){
        [self configureBubbleViewForGIFContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeLocation]) {
        [self configureBubbleViewForLocationContent];
    }
}

- (void)configureBubbleViewForTextContent
{
    LYRMessagePart *messagePart = self.message.parts[0];
    [self.label setText:[[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]];
    
    [self.mapGroup setHidden:YES];
    [self.imageGroup setHidden:YES];
}

- (void)configureBubbleViewForImageContent
{
    [self.map setHidden:YES];
    if (self.message.parts.count > 1) {
        CGRect screenRect = [[WKInterfaceDevice currentDevice] screenBounds];
        LYRMessagePart *dimensionPart = self.message.parts[2];
        CGSize size = ATLImageSizeForJSONData(dimensionPart.data);
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat ratio;
        if (width > height) {
            ratio = height / width;
            [self.image setWidth:screenRect.size.width];
            [self.image setHeight:screenRect.size.width * ratio];
        } else {
            ratio = width /  height;
            [self.image setWidth:screenRect.size.height *ratio];
            [self.image setHeight:screenRect.size.height];
        }
        LYRMessagePart *part = self.message.parts[1];
        [self.image setImageData:part.data];
    }
    
    [self.mapGroup setHidden:YES];
    [self.labelGroup setHidden:YES];
}

- (void)configureBubbleViewForGIFContent
{
    [self.mapGroup setHidden:YES];
    [self.labelGroup setHidden:YES];
}

- (void)configureBubbleViewForLocationContent
{
    LYRMessagePart *messagePart = self.message.parts[0];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    double lat = [dictionary[ATLLocationLatitudeKey] doubleValue];
    double lon = [dictionary[ATLLocationLongitudeKey] doubleValue];
    
    CLLocationCoordinate2D coodintate = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateRegion region =  MKCoordinateRegionMake(coodintate, MKCoordinateSpanMake(0.005, 0.005));
    [self.map setRegion:region];
    [self.map addAnnotation:coodintate withPinColor:WKInterfaceMapPinColorRed];
    
    [self.labelGroup setHidden:YES];
    [self.imageGroup setHidden:YES];
}

@end
