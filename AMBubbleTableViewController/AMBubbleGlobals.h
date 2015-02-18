//
//  AMBubbleGlobals.h
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

typedef enum {
	AMBubbleTableStyleDefault,
	AMBubbleTableStyleSquare,
	AMBubbleTableStyleFlat
} AMBubbleTableStyle;

typedef enum {
	AMBubbleCellTimestamp,
	AMBubbleCellSent,
	AMBubbleCellReceived,
    AMBubbleCellAction,
} AMBubbleCellType;

typedef enum {
	AMBubbleAccessoryUp,
	AMBubbleAccessoryDown
} AMBubbleAccessoryPosition;

#define kMessageTextWidth	(UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) ? 370.0f : 228.0f

@protocol AMBubbleTableDataSource <NSObject>
@required
-(NSString*)getContact;
- (int) getThreadType;
- (NSInteger)numberOfObjects;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)refIdForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSNumber *)messageStatusForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSNumber *)fromForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSNumber *)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath;
- (id) sections;

@optional
- (UIImage*)avatarForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString*)usernameForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor*)usernameColorForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol AMBubbleTableDelegate <NSObject>
- (void)didSendText:(NSString*)text;
- (void)resendTextForRefId:(NSString*)refId;
- (void)resendVoiceMessageWithRefId:(NSString*)refId;
- (void)forwardText:(NSString*)text;
- (void)forwardVoiceMessageWithBody:(NSString*)text andRefId:(NSString*)ref;
- (void)didSendVoiceMessageWithForwardUrl:(NSString*)forwardUrl andRemoteUrl:(NSString*)remoteUrl andLocalPath:(NSString*)localPath andDuration:(NSString *)duration;
- (BOOL)shouldEnableVoice;
@optional
- (void)swipedCellAtIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)frame andDirection:(UISwipeGestureRecognizerDirection)direction;
- (void)longPressedCellAtIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)frame;
@end

@protocol AMBubbleAccessory <NSObject>
@required
- (void)setOptions:(NSDictionary*)options;
- (void)setupView:(NSDictionary*)params;
@end

/* Options */

// Enables the short timestamp for every single message
FOUNDATION_EXPORT NSString *const AMOptionsTimestampEachMessage;

// Short Timestamp font
FOUNDATION_EXPORT NSString *const AMOptionsTimestampShortFont;

// Full timestamp font
FOUNDATION_EXPORT NSString *const AMOptionsTimestampFont;

// Avatar size
FOUNDATION_EXPORT NSString *const AMOptionsAvatarSize;

// Accessory class. Pass your custom accessory view's name as string
FOUNDATION_EXPORT NSString *const AMOptionsAccessoryClass;

// Accessory view size. Needed to get the cell height, adjust this when using a custom BubbleAccessory. The default view defaults to the Avatar Size
FOUNDATION_EXPORT NSString *const AMOptionsAccessorySize;

// Margin height for the bubble accessory view
FOUNDATION_EXPORT NSString *const AMOptionsAccessoryMargin;

// Full timestamp height
FOUNDATION_EXPORT NSString *const AMOptionsTimestampHeight;

// Incoming bubble image
FOUNDATION_EXPORT NSString *const AMOptionsImageIncoming;
FOUNDATION_EXPORT NSString *const AMOptionsImageIncomingSelected;

// Outgoing bubble image
FOUNDATION_EXPORT NSString *const AMOptionsImageOutgoing;
FOUNDATION_EXPORT NSString *const AMOptionsImageOutgoingSelected;

// Text bar background image
FOUNDATION_EXPORT NSString *const AMOptionsImageBar;

// Text bar front image
FOUNDATION_EXPORT NSString *const AMOptionsImageInput;

// Button image
FOUNDATION_EXPORT NSString *const AMOptionsImageButton;

// Button higlighted image
FOUNDATION_EXPORT NSString *const AMOptionsImageButtonHighlight;

// Textfield background
FOUNDATION_EXPORT NSString *const AMOptionsTextFieldBackground;

// Textfield font
FOUNDATION_EXPORT NSString *const AMOptionsTextFieldFont;

// Textfield font color
FOUNDATION_EXPORT NSString *const AMOptionsTextFieldFontColor;

// Table background
FOUNDATION_EXPORT NSString *const AMOptionsBubbleTableBackground;

// Accessory position (enum AMBubbleAccessoryPosition)
FOUNDATION_EXPORT NSString *const AMOptionsAccessoryPosition;

// Button Y offset
FOUNDATION_EXPORT NSString *const AMOptionsButtonOffset;

// Bubble text color
FOUNDATION_EXPORT NSString *const AMOptionsBubbleTextColor;

// Bubble text font
FOUNDATION_EXPORT NSString *const AMOptionsBubbleTextFont;

// Username text font
FOUNDATION_EXPORT NSString *const AMOptionsUsernameFont;

// Button Font
FOUNDATION_EXPORT NSString *const AMOptionsButtonFont;

// Enable Swipe gesture
FOUNDATION_EXPORT NSString *const AMOptionsBubbleSwipeEnabled;

// Enable Long press gesture
FOUNDATION_EXPORT NSString *const AMOptionsBubblePressEnabled;

@interface AMBubbleGlobals : NSObject

+ (NSDictionary*)defaultOptions;

// Styles
+ (NSDictionary*)defaultStyleDefault;
+ (NSDictionary*)defaultStyleSquare;
+ (NSDictionary*)defaultStyleFlat;

// Utils
+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;

@end