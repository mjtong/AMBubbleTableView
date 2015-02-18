//
//  AMBubbleTableCell.h
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleGlobals.h"
#import "PPLabel.h"
#import "ChikkaColor.h"
#import "ChikkaFont.h"

@class AMBubbleTableCell;

@protocol AMBubbleTableCellDelegate <NSObject>

-(void)resendButtonPressedForCell:(AMBubbleTableCell *)cell;
-(void)labelhasNoURLonTap;
-(void)longPressDetectedOnBubbleTableCell:(AMBubbleTableCell *)cell;
@end

@interface AMBubbleTableCell : UITableViewCell <PPLabelDelegate>

@property (nonatomic, weak)   NSDictionary* options;

@property (nonatomic, strong) UIButton*	resendButton;

@property (nonatomic, strong) UIImageView* bubbleView;

@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *participantName;

@property (nonatomic, strong) PPLabel *detailLabel;

@property(nonatomic, strong) NSArray* matches;

@property (nonatomic, strong) UIImageView *statusSMSImage;
@property (nonatomic, strong) UIImageView *participantImage;


@property (nonatomic, strong) UILabel *sentLabel;

@property int status;
@property int fromType;

@property BOOL isGroup;


@property (nonatomic, assign) id <AMBubbleTableCellDelegate> delegate;
@property BOOL isSelected;
@property(nonatomic,retain) NSIndexPath *indexPath;

- (id)initWithOptions:(NSDictionary*)options reuseIdentifier:(NSString *)reuseIdentifier isGroup:(BOOL)isGroup;

- (void)setupCellWithType:(AMBubbleCellType)type withWidth:(float)width andParams:(NSDictionary*)params;


-(void)showTimeAnimated:(BOOL)animated;
-(void)hideTimeAnimated:(BOOL)animated;

-(void)showSentStatusAnimated:(BOOL)animated;
-(void)hideSentStatusAnimated:(BOOL)animated;

@end
