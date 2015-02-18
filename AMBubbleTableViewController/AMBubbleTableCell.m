//
//  AMBubbleTableCell.m
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "ChikkaMessage.h"

#define kMinBubbleHeight 30.0f
#define kMinTextWidth 74.0f
#define kMessageBubblePaddingX 10.0f
#define kMessageBubblePaddingY 5.0f
#define kMessageContentPadding 8.0f

@interface AMBubbleTableCell ()

@end

@implementation AMBubbleTableCell


- (id)initWithOptions:(NSDictionary*)options reuseIdentifier:(NSString *)reuseIdentifier isGroup:(BOOL)isGroup
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isGroup = isGroup;
		self.options = options;
		self.backgroundColor = [ChikkaColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.bubbleView = [[UIImageView alloc] init];
        [self.bubbleView setUserInteractionEnabled:YES];
        [self addSubview:self.bubbleView];
        
        self.timeLabel = [[UILabel alloc] init];
        [self addSubview:self.timeLabel];
        
        self.resendButton = [[UIButton alloc] init];
        [self.resendButton setImage:[UIImage imageNamed:@"ic_messages-resend"] forState:UIControlStateNormal];
        [self.resendButton setImage:[UIImage imageNamed:@"ic_messages-resend_tap"] forState:UIControlStateHighlighted];
        [self.resendButton setHidden:YES];

        [self addSubview:self.resendButton];
        
        [self.resendButton addTarget:self action:@selector(resendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        

        self.detailLabel = [[PPLabel alloc] init];
        self.detailLabel.delegate = self;
        [self.bubbleView addSubview:self.detailLabel];
        
        self.statusLabel = [[UILabel alloc] init];
        [self.statusLabel setFont:[ChikkaFont smallFont]];
        [self.statusLabel setBackgroundColor:[ChikkaColor clearColor]];
        [self addSubview:self.statusLabel];
        
        self.statusSMSImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_sent-as-sms"]];
        [self addSubview:self.statusSMSImage];
        
        
        self.sentLabel = [[UILabel alloc] init];
        [self.sentLabel setFont:[ChikkaFont smallFont]];
        [self.sentLabel setBackgroundColor:[ChikkaColor clearColor]];
        [self addSubview:self.sentLabel];
        
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:longPressGesture];
        
        if(self.isGroup){
            self.participantName = [[UILabel alloc] init];
            [self.participantName setFont:[ChikkaFont smallFont]];
            [self.participantName setBackgroundColor:[ChikkaColor clearColor]];
            [self addSubview:self.participantName];
            
            self.participantImage = [[UIImageView alloc] init];
            [self.participantImage setBackgroundColor:[ChikkaColor clearColor]];
            [self addSubview:self.participantImage];
        }

    }
    return self;
}


- (void)setupCellWithType:(AMBubbleCellType)type withWidth:(float)width andParams:(NSDictionary*)params
{
    
	UIFont* textFont = [ChikkaFont mediumFont];
    
	CGRect content = self.contentView.frame;
	content.size.width = width;
	self.contentView.frame = content;

	// Configure the cell to show the message in a bubble. Layout message cell & its subviews.
	CGSize sizeText = [params[@"text"] sizeWithFont:textFont
								  constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
									  lineBreakMode:NSLineBreakByWordWrapping];
	
    if (sizeText.width < kMinTextWidth){
        sizeText.width = kMinTextWidth;
    }
    
    [self.detailLabel setBackgroundColor:[ChikkaColor clearColor]];
	[self.detailLabel setFont:textFont];
	[self.detailLabel setNumberOfLines:0];
    
    [self.timeLabel setBackgroundColor:[ChikkaColor clearColor]];
    [self.timeLabel setFont:[ChikkaFont smallFont]];
    [self.timeLabel setNumberOfLines:0];
    [self.timeLabel setText:params[@"date"]];

     self.status = [params[@"status"] intValue];
    
    sizeText.width = sizeText.width + 1.0f;
    int moarPadding = (self.isGroup) ? 30 : 0;
	// Right Bubble
	if (type == AMBubbleCellSent) {
        NSLog(@"self.group moarPadding : %d", moarPadding);
        CGRect background = CGRectMake(width - sizeText.width - 2*kMessageContentPadding - kMessageBubblePaddingX -moarPadding,
                                       kMessageBubblePaddingY,
                                       sizeText.width + 2*kMessageContentPadding,
                                       sizeText.height + 2*kMessageContentPadding);
        
        

        
        
        CGRect textFrame = CGRectMake(kMessageContentPadding,
                                      kMessageContentPadding,
                                      sizeText.width,
                                      sizeText.height);
        if(self.isGroup){
//            [self.participantImage setImage:[UIImage imageNamed:@"profile-pic.png"]];
                [self.participantImage sd_setImageWithURL:[NSURL URLWithString:[UserDefaultsUtil getStringValueForKey:kCTMProfileThumbImage withDefaultValue:nil]]  placeholderImage:[UIImage imageNamed:@"profile-pic.png"] options:SDWebImageRefreshCached];
            [self.participantImage setFrame:CGRectMake(width - 30 - kMessageContentPadding, sizeText.height - 10, 30, 30)];
            [self.participantImage.layer setCornerRadius:15];
            self.participantImage.layer.masksToBounds = YES;
        }
        
		[self setupBubbleWithType:type
					   background:background
						textFrame:textFrame
						  andText:params[@"text"]];

	}

	if (type == AMBubbleCellReceived) {

		CGRect background = CGRectMake(moarPadding + kMessageBubblePaddingX,
                                       kMessageBubblePaddingY,
                                       sizeText.width + 2*kMessageContentPadding,
                                       sizeText.height + 2*kMessageContentPadding);
		
        CGRect textFrame = CGRectMake(kMessageContentPadding, kMessageContentPadding, sizeText.width, sizeText.height);
        if(self.isGroup){
//            [self.participantImage setImage:[UIImage imageNamed:@"profile-pic.png"]];
              [self.participantImage sd_setImageWithURL:[NSURL URLWithString:params[@"avatar"]]  placeholderImage:[UIImage imageNamed:@"profile-pic.png"] options:SDWebImageRefreshCached];
            [self.participantImage setFrame:CGRectMake(kMessageBubblePaddingY, sizeText.height - 10, 30, 30)];
            [self.participantImage.layer setCornerRadius:15];
            self.participantImage.layer.masksToBounds = YES;
            [self.participantName setText:params[@"name"]];
            
        }
		[self setupBubbleWithType:type
					   background:background
						textFrame:textFrame
						  andText:params[@"text"]];
	}
	
}

- (void)setupBubbleWithType:(AMBubbleCellType)type background:(CGRect)frame textFrame:(CGRect)textFrame andText:(NSString*)text
{

    if (frame.size.height<kMinBubbleHeight){
        NSLog(@"bg: %@", NSStringFromCGRect(frame));
        frame.size.height=kMinBubbleHeight;
    }
    
    [self.bubbleView setFrame:frame];
    [self.bubbleView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    
    CGRect labelFrame = textFrame;
    [self.detailLabel setFrame:labelFrame];
    [self.detailLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.detailLabel setText:text];
    

    [self layoutSubviews];

    
}

-(void) layoutSubviews {
    
    UIImage *bubbleImage = nil;
    UIEdgeInsets bubbleInsets = UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f);

    CGRect textFrame = self.detailLabel.frame;
    CGRect bubbleFrame = self.bubbleView.frame;
    CGRect statusFrame = CGRectZero;
    CGRect timeFrame = CGRectZero;
    CGRect smsImgFrame = CGRectZero;
    CGSize statusSize = CGSizeZero;
    CGSize timeSize = CGSizeZero;

    CGRect sentFrame = CGRectZero;
    CGSize sentSize = CGSizeZero;
    
    
    CGSize participantNameSize = CGSizeZero;
    //[self.resendButton setFrame:CGRectMake(self.bubbleView.frame.origin.x - 35, (self.bubbleView.frame.size.height-24)/2 , 24, 24)];
    
    [self.resendButton setFrame:CGRectMake(self.bubbleView.frame.origin.x - 35, (bubbleFrame.size.height-24)/2 + bubbleFrame.origin.y, 24, 24)];
    
	if (self.fromType == MessageFromContact) {

        [self.detailLabel setTextColor:[ChikkaColor whiteColor]];
        [self.timeLabel setTextColor:[ChikkaColor grayColor]];

 
        //[self.timeLabel setFrame:timeFrame];
        
        if (self.isSelected){
            [self.bubbleView setImage:[[UIImage imageNamed:@"message-received_on-pressed"] resizableImageWithCapInsets:bubbleInsets]];
        }
        else {

            [self.bubbleView setImage:[[UIImage imageNamed:@"message-received"] resizableImageWithCapInsets:bubbleInsets]];
        }

        [self.resendButton setHidden:YES];
//        [self.statusLabel setHidden:YES];
        [self.statusSMSImage setHidden:YES];
        [self.timeLabel setHidden:NO];
      
        
        if(self.isGroup){
            [self.participantName setHidden:NO];
            
            participantNameSize = [self.participantName.text sizeWithFont:[ChikkaFont smallFont]
                                                        constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                                            lineBreakMode:NSLineBreakByWordWrapping];
            [self.participantName setFrame:CGRectMake(bubbleFrame.origin.x + kMessageContentPadding, bubbleFrame.origin.y + bubbleFrame.size.height, participantNameSize.width + 5, participantNameSize.height)];
        }
	} else {
        
        [self.detailLabel setTextColor:[ChikkaColor darkGrayColor]];
        [self.timeLabel setTextColor:[ChikkaColor grayColor]];
        [self.statusLabel setTextColor:[ChikkaColor grayColor]];
        [self.sentLabel setTextColor:[ChikkaColor grayColor]];
        
        if (self.status == MessageStatusFailed || self.status == MessageStatusFailedCredits || self.status == MessageStatusSending){
            
            if(self.isSelected){
                bubbleImage = [[UIImage imageNamed:@"message-failed_on-pressed"] resizableImageWithCapInsets:bubbleInsets];
            }
            else {
                bubbleImage = [[UIImage imageNamed:@"message-failed"] resizableImageWithCapInsets:bubbleInsets];
            }
            
        }else {
            if(self.isSelected){
                bubbleImage = [[UIImage imageNamed:@"message-sent_on-pressed"] resizableImageWithCapInsets:bubbleInsets];
            }
            else {
                bubbleImage = [[UIImage imageNamed:@"message-sent"] resizableImageWithCapInsets:bubbleInsets];
            }
        }
        
        [self.bubbleView setImage:bubbleImage];
     
       
        
        if (self.status == MessageStatusFailed || self.status == MessageStatusFailedCredits){
            [self.statusLabel setText:@"Failed"];
            [self.resendButton setHidden:NO];
//            [self.statusLabel setHidden:NO];
            [self.statusSMSImage setHidden:YES];
//            [self.timeLabel setHidden:NO];

            [self.sentLabel setText:@""];
        }
        else if (self.status == MessageStatusSending) {
            //[self.statusLabel setText:@"Sending..."];
            [self.timeLabel setText:@"Sending..."];
            [self.resendButton setHidden:YES];
//            [self.statusLabel setHidden:NO];
            [self.statusSMSImage setHidden:YES];

        }
        else if (self.status == MessageStatusSentViaSMS) {
            [self.statusLabel setText:@"Sent via SMS"];
//            [self.statusLabel setHidden:YES];
            [self.resendButton setHidden:YES];
            [self.statusSMSImage setHidden:YES];
//            [self.timeLabel setHidden:NO];

            [self.sentLabel setText:@"Sent"];
            
        }
        else {
            [self.statusLabel setText:@"Sent"];
            [self.resendButton setHidden:YES];
//            [self.statusLabel setHidden:YES];
            [self.statusSMSImage setHidden:YES];
//            [self.timeLabel setHidden:NO];
            
            [self.sentLabel setText:@"Sent"];
        }

        if(self.isGroup){
            [self.participantName setFrame:CGRectZero];
        }

        
    }
    
    timeSize = [self.timeLabel.text sizeWithFont:[ChikkaFont smallFont]
                               constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
//    timeFrame = CGRectMake(bubbleFrame.origin.x, bubbleFrame.size.height, timeSize.width, timeSize.height);

    
    statusSize = [self.statusLabel.text sizeWithFont:[ChikkaFont smallFont]
                                   constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    
//    statusFrame = CGRectMake(bubbleFrame.size.width - timeSize.width - statusSize.width - 15.0f, bubbleFrame.size.height - timeSize.height - 5.0f, statusSize.width, statusSize.height);

    sentSize = [self.sentLabel.text sizeWithFont:[ChikkaFont smallFont]
                               constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    
    smsImgFrame = CGRectMake(bubbleFrame.size.width - timeSize.width - timeSize.height*1.8f - 15.0f, bubbleFrame.size.height - timeSize.height - 4.0f, timeSize.height*1.8f, timeSize.height);
    
    
    
    if (((timeSize.width + statusSize.width + 5.0f) > textFrame.size.width) && (self.status == MessageStatusSentViaSMS || self.status == MessageStatusFailed || self.status == MessageStatusFailedCredits)) {
//        NSLog(@"IFFFF");
        statusFrame = CGRectMake(bubbleFrame.origin.x + bubbleFrame.size.width - statusSize.width - kMessageContentPadding, bubbleFrame.origin.y + bubbleFrame.size.height, statusSize.width, statusSize.height);
        timeFrame = CGRectMake(bubbleFrame.origin.x + bubbleFrame.size.width - timeSize.width - statusSize.width - 5.0f - kMessageBubblePaddingX , bubbleFrame.origin.y + bubbleFrame.size.height, timeSize.width, timeSize.height);
          sentFrame = CGRectMake(bubbleFrame.origin.x + kMessageContentPadding, bubbleFrame.origin.y + bubbleFrame.size.height, sentSize.width, sentSize.height);
    }
    else {

               NSLog(@"ELSEEEE");
        timeFrame = CGRectMake(bubbleFrame.origin.x + kMessageContentPadding + self.participantName.frame.size.width, bubbleFrame.origin.y + bubbleFrame.size.height, timeSize.width, timeSize.height);

        statusFrame = CGRectMake(timeFrame.origin.x + timeSize.width + 5.0f, timeFrame.origin.y, statusSize.width, statusSize.height);
          sentFrame = CGRectMake(timeFrame.origin.x, timeFrame.origin.y, sentSize.width, sentSize.height);
    }
    
    
    [self.timeLabel setFrame:timeFrame];
    [self.statusLabel setFrame:statusFrame];
    [self.statusSMSImage setFrame:smsImgFrame];


    
//    sentFrame = CGRectMake(bubbleFrame.size.width - sentSize.width - 10.0f, bubbleFrame.size.height - sentSize.height - 5.0f, sentSize.width, sentSize.height);
//     sentFrame = CGRectMake(timeFrame.origin.x, timeFrame.origin.y, sentSize.width, sentSize.height);
    
    [self.sentLabel setFrame:sentFrame];
    
    
    
    
    
    
    //PPLABEL
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if ([self.detailLabel.text length]>0){
        self.matches = [detector matchesInString:self.detailLabel.text options:0 range:NSMakeRange(0, self.detailLabel.text.length)];
    }
    
    [self highlightLinksWithIndex:NSNotFound];
    
    
}
-(void)resendButtonPressed
{
    //NSLog(@"resendButtonPressed");
    if ([self.delegate respondsToSelector:@selector(resendButtonPressedForCell:)]) {
        [self.delegate resendButtonPressedForCell:self];
	}
}


#pragma mark - PPLabel

#pragma mark -

- (BOOL)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
   // NSLog(@"didBeginTouch");
    
    [self highlightLinksWithIndex:charIndex];
    return YES;
}

- (BOOL)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
    return YES;
}

- (BOOL)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
               // NSLog(@"openURL: %@", match.URL);
                [[UIApplication sharedApplication] openURL:match.URL];
                return YES;
                //break;
            }
        }
        
    }

    if ([self.delegate respondsToSelector:@selector(labelhasNoURLonTap)]){
        [self.delegate labelhasNoURLonTap];
    }
    return YES;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self highlightLinksWithIndex:NSNotFound];
    
    return YES;
}

#pragma mark -

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [self.detailLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[ChikkaColor darkGrayColor] range:matchRange];
            }
            else {
                if (self.fromType == MessageFromUser) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[ChikkaColor blueColor] range:matchRange];
                }
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    self.detailLabel.attributedText = attributedString;
}

#pragma mark - Long Press Gesture Recognizer


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan){
        if ([self.delegate respondsToSelector:@selector(longPressDetectedOnBubbleTableCell:)]) {
            [self.delegate longPressDetectedOnBubbleTableCell:self];
        }
    }

}

#pragma mark - show/hide time


-(void)showTimeAnimated:(BOOL)animated
{
    [self.sentLabel setAlpha:0.0f];
    
    if (self.status == MessageStatusFailed || self.status == MessageStatusFailedCredits){
        //if status is failed or sending, it should ALWAYS SHOW
        [self.timeLabel setAlpha:1.0];
        [self.statusLabel setAlpha:1.0];
        
        //[self.statusSMSImage setAlpha:0.0];
    }
    else if (self.status == MessageStatusSending) {
                NSLog(@"TEXT messageStatus SENDING");
        [self.timeLabel setAlpha:1.0];
        [self.statusLabel setAlpha:0.0];
        //[self.statusSMSImage setAlpha:0.0];
    }
    else {
        //else hide status label
        [self.statusLabel setAlpha:0.0];
        
        [self.timeLabel setAlpha:0.0f];
        //[self.statusSMSImage setAlpha:0.0];
        
        if (animated ) {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                             animations:^(void)
             {
                 [self.timeLabel setAlpha:1.0];
                 if (self.status == MessageStatusSentViaSMS) {
                     //[self.statusSMSImage setAlpha:1.0];
                     [self.statusLabel setAlpha:1.0];
                 }
             }
                             completion:^(BOOL finished)
             {
                 NSLog(@"time was shown");
             }];
        }
        else {
            [self.timeLabel setAlpha:1.0];
            if (self.status == MessageStatusSentViaSMS) {
//                [self.statusSMSImage setAlpha:1.0];
                     [self.statusLabel setAlpha:1.0];
            }
        }
    }

   
    
}

-(void)hideTimeAnimated:(BOOL)animated
{
    [self.sentLabel setAlpha:0.0f];
    
    if (self.status == MessageStatusFailed || self.status == MessageStatusFailedCredits){
        //if status is failed or sending, it should ALWAYS SHOW
        [self.timeLabel setAlpha:1.0];
        [self.statusLabel setAlpha:1.0];

//        [self.statusSMSImage setAlpha:0.0];
    }
    else if (self.status == MessageStatusSending) {
        [self.timeLabel setAlpha:1.0];
        [self.statusLabel setAlpha:0.0];
//        [self.statusSMSImage setAlpha:0.0];
    }
    else {
        //else hide status label
        [self.statusLabel setAlpha:0.0];
        
        [self.timeLabel setAlpha:1.0];
        if (self.status == MessageStatusSentViaSMS) {
//            [self.statusSMSImage setAlpha:1.0];
            [self.statusLabel setAlpha:1.0];
        }
        
        if (animated ) {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                             animations:^(void)
             {
                 [self.timeLabel setAlpha:0.0];
//                 [self.statusSMSImage setAlpha:0.0];
                     [self.statusLabel setAlpha:0.0];

             }
                             completion:^(BOOL finished)
             {
//                 NSLog(@"time was hidden");
             }];
        }
        else {
            [self.timeLabel setAlpha:0.0];
//            [self.statusSMSImage setAlpha:0.0];
                     [self.statusLabel setAlpha:0.0];
        }
    }
    
}

-(void)showSentStatusAnimated:(BOOL)animated{

    NSLog(@"showSentStatusAnimated");
    
    [self.timeLabel setAlpha:0.0];
    [self.statusLabel setAlpha:0.0];
    [self.statusSMSImage setAlpha:0.0];
    [self.sentLabel setAlpha:0.0f];
    
    if (animated ) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             [self.sentLabel setAlpha:1.0f];
             
             
         }
                         completion:^(BOOL finished)
         {
             NSLog(@"SENT STATUS WAS SHOWN");
         }];
    }
    else {
        [self.sentLabel setAlpha:1.0f];
    }
}

-(void)hideSentStatusAnimated:(BOOL)animated {
    
    NSLog(@"showSentStatusAnimated");
    
    [self.timeLabel setAlpha:0.0];
    [self.statusLabel setAlpha:0.0];
    [self.statusSMSImage setAlpha:0.0];
    [self.sentLabel setAlpha:1.0f];
    
    if (animated ) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             [self.sentLabel setAlpha:0.0f];
             
             
         }
                         completion:^(BOOL finished)
         {
             NSLog(@"SENT STATUS WAS HIDDEN");
         }];
    }
    else {
        [self.sentLabel setAlpha:0.0f];
    }
}

-(void)setThumbnail:(NSString*)photoUrl andName:(NSString *)name{
    //[self.thumbnailImageView setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"img_contact.png"] options:SDWebImageRefreshCached];
    [self.participantImage setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"profile-pic.png"] options:SDWebImageRefreshCached];
    [self.participantName setText:name];
}

@end
