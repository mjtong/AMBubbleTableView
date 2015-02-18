//
//  AMBubbleFlatAccessoryView.m
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 02/08/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleFlatAccessoryView.h"
#import <QuartzCore/QuartzCore.h>
#import "ChikkaMessage.h"

@interface AMBubbleFlatAccessoryView ()

@property (nonatomic, weak)   NSDictionary* options;
@property (nonatomic, strong) UILabel*		labelTimestamp;
@property (nonatomic, strong) UIImageView*	imageCheck;
@property (nonatomic, strong) UIImageView*	imageAvatar;

@end

@implementation AMBubbleFlatAccessoryView

- (id)init
{
    self = [super init];
    if (self) {
		//[self setBackgroundColor:[UIColor redColor]];
        
		[self setClipsToBounds:YES];
		
		self.imageAvatar = [[UIImageView alloc] init];
		self.labelTimestamp = [[UILabel alloc] init];
		[self addSubview:self.imageAvatar];
		[self addSubview:self.labelTimestamp];
		
		self.imageAvatar.layer.cornerRadius = 2.0;
		self.imageAvatar.layer.masksToBounds = YES;
		
		[self.labelTimestamp setTextColor:[UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1]];
		[self.labelTimestamp setTextAlignment:NSTextAlignmentCenter];
		[self.labelTimestamp setBackgroundColor:[UIColor clearColor]];
//		[self.labelTimestamp setBackgroundColor:[UIColor blueColor]];
    }
    return self;
}

- (void)setOptions:(NSDictionary *)options
{
	_options = options;
	[self.labelTimestamp setFont:self.options[AMOptionsTimestampShortFont]];
}

- (void)setupView:(NSDictionary*)params
{
    if (params[@"status"]){
        CGSize sizeTime = CGSizeZero;
        
        int status = [params[@"status"] intValue];
        
        if (status == MessageStatusFailed || status == MessageStatusFailedCredits ){

            [self.labelTimestamp setText:@"Failed"];
            [self.labelTimestamp setTextColor:[UIColor redColor]];
            
            if ([self.options[AMOptionsTimestampEachMessage] boolValue]) {
                sizeTime = [self.labelTimestamp.text sizeWithFont:self.options[AMOptionsTimestampShortFont]
                                       constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByWordWrapping];
            }
        }else if (status == MessageStatusSending) {
            
            [self.labelTimestamp setText:@"Sending..."];
            [self.labelTimestamp setTextColor:[UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1]];
            
            //CGSize sizeTime = CGSizeZero;
            if ([self.options[AMOptionsTimestampEachMessage] boolValue]) {
                sizeTime = [self.labelTimestamp.text sizeWithFont:self.options[AMOptionsTimestampShortFont]
                                                constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                                    lineBreakMode:NSLineBreakByWordWrapping];
            }
            
        }else if (status == MessageStatusSent) {
            
            [self.labelTimestamp setText:@"Sent"];
            [self.labelTimestamp setTextColor:[UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1]];
            
            
            if ([self.options[AMOptionsTimestampEachMessage] boolValue]) {
                sizeTime = [self.labelTimestamp.text sizeWithFont:self.options[AMOptionsTimestampShortFont]
                                                constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                                    lineBreakMode:NSLineBreakByWordWrapping];
            }
            
        }else if (status == MessageStatusSentViaSMS) {
            
            [self.labelTimestamp setText:@"Sent via SMS"];
            [self.labelTimestamp setTextColor:[UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1]];
            
            if ([self.options[AMOptionsTimestampEachMessage] boolValue]) {
                sizeTime = [self.labelTimestamp.text sizeWithFont:self.options[AMOptionsTimestampShortFont]
                                                constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                                    lineBreakMode:NSLineBreakByWordWrapping];
            }
            
        }else {
            [self.labelTimestamp setTextColor:[UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1]];
        }
        
        [self.labelTimestamp setFrame:CGRectMake(0, 4, sizeTime.width, sizeTime.height)];

        [self setFrame:CGRectMake(0, 0, self.labelTimestamp.frame.size.width, self.labelTimestamp.frame.size.height)];
    }

}


@end
