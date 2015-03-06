//
//  AMBubbleTableViewController.h
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleGlobals.h"
#import "AMBubbleTableCell.h"
#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceMessageCell.h"
#import "ChikkaColor.h"
#import "ChikkaFont.h"
#import <GoogleMobileAds/GADBannerView.h>
#import "MDLoadingView.h"


@interface AMBubbleTableViewController : BaseViewController <AMBubbleTableCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate, GADBannerViewDelegate, MDLoadingViewDelegate>
{
    CGFloat keyboardHeight;
    AMBubbleTableCell *longPressCell;
    NSIndexPath *longPressIndexPath;
    UIActionSheet *moreActionSheet;
    UIAlertView *alertViewDelete;
    
    AVAudioPlayer *audioPlayer;
    NSIndexPath *playingIndexPath;
    VoiceMessageCell *toPlayMessageCell;
    NSString *downloadedMessageId;
    NSTimer *playerUpdater;
    NSTimeInterval playingCurrentTime;
    NSTimeInterval playingDuration;

    NSMutableDictionary *downloadingRefIDs;
    NSMutableDictionary *sentRefIDsToAnimate;
    NSMutableDictionary *timeRefIDsToAnimate;
    
    BOOL shouldShowTime;
    NSTimer* timer;
    
    GADBannerView *bannerView_;
    BOOL hasAdLoaded;
    BOOL mustShowAd;
    
}
@property (nonatomic, strong) UITableView*	tableView;
@property (nonatomic, strong) UITextView*	textView;
@property (nonatomic, assign) id<AMBubbleTableDataSource> dataSource;
@property (nonatomic, assign) id<AMBubbleTableDelegate> delegate;

@property BOOL isGroup;
@property BOOL shouldCreateGroup;
@property NSString *groupNameToCreate;
@property NSArray *groupMembersToCreate;


@property (nonatomic, strong) UILabel *headerErrorLabel;
@property (nonatomic, strong) UILabel *footerErrorLabel;


- (void)reloadTableScrollingToBottom:(BOOL)scroll;
- (void)setBubbleTableOptions:(NSDictionary *)options;
- (void)setTableStyle:(AMBubbleTableStyle)style;
- (void)scrollToBottomAnimated:(BOOL)animated;

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
//-(void)setShouldEnableVoice:(BOOL)enable;

-(void) showSentStatusForRefId:(NSString*)refId andIndexPath:(NSIndexPath*)indexPath;

-(void)refreshRowsAtTop;
-(void)refreshRowsAtBottom;

@end
