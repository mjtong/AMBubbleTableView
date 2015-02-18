//
//  AMBubbleTableViewController.m
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleTableViewController.h"
#import "MessageInputView.h"
#import "ChikkaMessage.h"
#import "DataDelegate.h"
#import "PPLabel.h"
#import "RecordingInputView.h"
#import "GAIDictionaryBuilder.h"

#import "GroupActionCell.h"

#import "SVPullToRefresh.h"
#import "Thread.h"
#import "NameCacheUtil.h"



#define kInputHeight 40.0f
//#define kLineHeight 30.0f
#define kButtonWidth 78.0f

#define kHeightSectionHeader 20.0f
#define IS_PORTRAIT     UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])
#define IS_LANDSCAPE    UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
@interface AMBubbleTableViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MessageInputDelegate, RecordingInputDelegate, VoiceMessageCellDelegate>

@property (strong, nonatomic) NSMutableDictionary*	options;
//@property (nonatomic, strong) UIImageView*	imageInput;
//@property (nonatomic, strong) UITextView*	textView;
//@property (nonatomic, strong) UIImageView*	imageInputBack;
//@property (nonatomic, strong) UIButton*		buttonSend;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) UITextView*	tempTextView;
//@property (nonatomic, assign) float			previousTextFieldHeight;
@property (nonatomic, strong) MessageInputView *messageInputView;
@property (nonatomic, strong) RecordingInputView *recordingView;

@end

@implementation AMBubbleTableViewController


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation");
    if ([self.recordingView isRecording]){
        
    }
    else {
        
    }
    
}

-(BOOL)shouldAutorotate{
    NSLog(@"shouldAutorotate");
    if ([self.recordingView isRecording]){
        return NO;
    }
    else {
        return YES;
    }
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
//{
//    CGFloat actualPosition = scrollView_.contentOffset.y;
//    CGFloat contentHeight = scrollView_.contentSize.height - (10);
//    if (actualPosition >= contentHeight) {
//        NSLog(@"ito na ito na ito na ito na");
//        //        [self.newsFeedData_ addObjectsFromArray:self.newsFeedData_];
//        //        [self.tableView reloadData];
//    }
//}

- (void)viewDidLoad
{
    [self.tableView setTag:kMainContainer];
    
    isEditable = YES;
    
    //    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [super viewDidLoad];
    
    
    
    
    //    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
}

- (void)setBubbleTableOptions:(NSDictionary *)options
{
    [self.options addEntriesFromDictionary:options];
}

- (NSMutableDictionary*)options
{
    if (_options == nil) {
        _options = [[AMBubbleGlobals defaultOptions] mutableCopy];
    }
    return _options;
}

- (void)setTableStyle:(AMBubbleTableStyle)style
{
    switch (style) {
        case AMBubbleTableStyleDefault:
            [self.options addEntriesFromDictionary:[AMBubbleGlobals defaultStyleDefault]];
            break;
        case AMBubbleTableStyleSquare:
            [self.options addEntriesFromDictionary:[AMBubbleGlobals defaultStyleSquare]];
            break;
        case AMBubbleTableStyleFlat:
            [self.options addEntriesFromDictionary:[AMBubbleGlobals defaultStyleFlat]];
            break;
        default:
            break;
    }
}

-(void)infiniteAnimationStarted{
    NSLog(@"infiniteAnimationStarted");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupView];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:NO];
    [self showTimeInTableView];
    [self startTimer];
      [self.messageInputView adjustViewHeight];
    if ([self.delegate shouldEnableVoice]) {
        [self.messageInputView showMicrophoneButton];
    }
    else {
        [self.messageInputView showSendButton];
    }
}



-(void)dealloc{
    NSLog(@"test for dealloc in Bubble View");
    
    self.delegate = nil;
    self.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFailedFetchingNewerMessages object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFailedFetchingOlderMessages object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFinishedFetchingNewerMessages object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFinishedFetchingOlderMessages object:nil];
}


-(void)viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFailedFetchingNewerMessages object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFailedFetchingOlderMessages object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFinishedFetchingNewerMessages object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFinishedFetchingOlderMessages object:nil];
    [super viewDidUnload];
}




-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playDownloadedMessage:)
                                                 name:kCTMFinishedDownloadingVoiceMessage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failedDownloadVoiceMessage:)
                                                 name:kCTMFailedDownloadVoiceMessage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playSoundForVoiceMessageStatus:)
                                                 name:kCTMPlaySoundForVoiceMessageStatus
                                               object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(showSentStatus:)
    //                                                 name:kCTMDidReceiveAcknowledgementForRefId
    //                                               object:nil];
    
  
    NSLog(@"viewDidAppear tableView: %@", self.tableView);
    NSLog(@"INSETS: %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
}


//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
// 
//}



-(void)playDownloadedMessage:(NSNotification*) notification{
    NSLog(@"download VM success");
    
    NSString *refId = [[notification userInfo] valueForKey:kCTMKeyMessageId];
    NSLog(@"refid: %@", refId);
    
    NSIndexPath *index = [downloadingRefIDs objectForKey:refId];
    
    NSString *otherRefId = [self.dataSource refIdForRowAtIndexPath:index];
    
    if ([refId isEqualToString:otherRefId]){
        //same ref id, so we have the right bubble
        VoiceMessageCell *vmcell = (VoiceMessageCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index.row inSection:index.section]];
        
        [vmcell setIsDownloading:NO];
        downloadedMessageId = refId;
        
        NSString *local = [[notification userInfo] valueForKey:kCTMVoiceLocalPath];
        NSLog(@"localpath: %@", local);
        toPlayMessageCell.localPath = local;
        
        if(![audioPlayer isPlaying] && [toPlayMessageCell.refId isEqualToString:downloadedMessageId]){
            NSLog(@"play downloaded message!!!");
            [self playButtonPressedForVoiceMessageCell:toPlayMessageCell];
        }
        else {
            [vmcell setIsPlaying:NO];
        }
    }
    else {
        [self.tableView reloadData];
    }
    
    
    
    [downloadingRefIDs removeObjectForKey:refId];
    NSLog(@"REMOVING AN OBJECT! downloadingRefIds: %@", downloadingRefIDs);
}

-(void)failedDownloadVoiceMessage:(NSNotification*) notification{
    NSLog(@"download VM failed BUBBLE");
    NSString *refId = [[notification userInfo] valueForKey:kCTMKeyMessageId];
    NSLog(@"refid: %@", refId);
    
    NSIndexPath *index = [downloadingRefIDs objectForKey:refId];
    
    NSString *otherRefId = [self.dataSource refIdForRowAtIndexPath:index];
    
    if ([refId isEqualToString:otherRefId]){
        //same ref id, so we have the right bubble
        
        
        VoiceMessageCell *vmcell = (VoiceMessageCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index.row inSection:index.section]];
        
        [vmcell setIsDownloading:NO];
        [vmcell setIsPlaying:NO];
        
        //        if ([vmcell respondsToSelector:@selector(setIsDownloading:)]){
        //            [vmcell setIsDownloading:NO];
        //            }
        //        if ([vmcell respondsToSelector:@selector(setIsPlaying:)]){
        //            [vmcell setIsPlaying:NO];
        //            }
        
        
    }
    
    [downloadingRefIDs removeObjectForKey:refId];
    NSLog(@"REMOVING AN OBJECT! downloadingRefIds: %@", downloadingRefIDs);
    [ChikkaAlertView showAlertViewWithMessage:ERROR_UNABLE_TO_DOWNLOAD];
    
}

-(void)playSoundForVoiceMessageStatus:(NSNotification*)notification{
    
}

-(void)didReceiveVoiceMessage:(NSNotification*)notification{
    
}


//-(void)showSentStatus:(NSNotification*)notification{
//    NSString *refId = [[notification userInfo] valueForKey:kCTMKeyMessageId];
//    NSString *contact= [[notification userInfo] valueForKey:kCTMKeyMessageContact];
//    if ([contact isEqualToString:[self.dataSource getContact]]) {
//
//    }
//}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    //	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    //	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    
    [self.messageInputView resignFirstResponder];
    [self.recordingView hideInTargetView:self.view];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFinishedDownloadingVoiceMessage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFailedDownloadVoiceMessage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMDidReceiveAcknowledgementForRefId object:nil];
    
    
    [self stopPlayback];
    
    if([self isMovingFromParentViewController]){
//        self.delegate = nil;
//        self.dataSource = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFailedFetchingNewerMessages object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFailedFetchingOlderMessages object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFinishedFetchingNewerMessages object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCTMFinishedFetchingOlderMessages object:nil];
       
    }
    
    if(timer){
        [timer invalidate];
        timer = nil;
    }
    
    [super viewWillDisappear:animated];
}
- (void)setupView
{
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(dismissKeyboardAndShowTime:)];
    gestureRecognizer.delegate = self;
    
    // Table View
    CGRect tableFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    //for table view style plain
    //self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    
    //for grouped (way to remove floating headers)
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    self.tableView.backgroundView = nil;
    
    [self.tableView addGestureRecognizer:gestureRecognizer];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setBackgroundColor:self.options[AMOptionsBubbleTableBackground]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //    	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.view addSubview:self.tableView];
    if(IS_LANDSCAPE){
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
        
    }else{
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        
    }
    bannerView_.adUnitID = kAdUnitId;
    bannerView_.rootViewController = self;
    bannerView_.delegate = self;
    [bannerView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    hasAdLoaded = NO;
    mustShowAd = YES;
    if([UserDefaultsUtil getIntValueForKey:kConnectionStatus withDefaultValue:-1] == CSConnected && !hasAdLoaded){
        [self.view addSubview:bannerView_];
        GADRequest *request = [GADRequest request];
        [bannerView_ loadRequest:request];
    }
    
    //initialize Recording Input View
    self.recordingView = [[RecordingInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216)];
    [self.recordingView setDelegate:self];
    [self.recordingView setShouldShowNoteLabel:YES];
    [self.view addSubview:self.recordingView];
    
    
    //initialize Message Input View
    self.messageInputView = [[MessageInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    self.messageInputView.delegate = self;
    
    [self.view addSubview:self.messageInputView];
    
    //do not add messageInputView as subview if thread of type admin
    if ([self.dataSource getThreadType] == ThreadTypeAdmin) {
        [self.messageInputView removeFromSuperview];
    }
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                           0.0f,
                                           self.messageInputView.frame.size.height,
                                           0.0f);
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    __weak AMBubbleTableViewController *weakSelf = self;

    [self.tableView addInfiniteScrollinhWithActionHandler:^{
        [weakSelf refreshRowsAtBottom];
    } position:SVInfiniteScrollingPositionBottom];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refreshRowsAtTop];
    } position:SVPullToRefreshPositionTop];

    
    UIView *errorLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    [activityIndicator startAnimating];
    activityIndicator.center = errorLabel.center;
    activityIndicator.hidesWhenStopped = YES;
    
    [errorLabel addSubview:activityIndicator];
    [self.tableView.pullToRefreshView setCustomView:errorLabel forState:SVPullToRefreshStateAll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideEditMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    downloadingRefIDs = [[NSMutableDictionary alloc] init];
    sentRefIDsToAnimate = [[NSMutableDictionary alloc] init];
    timeRefIDsToAnimate = [[NSMutableDictionary alloc] init];
    
    shouldShowTime = NO;
    
    //NOTE: TESTING LANG DEC 3 2014
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedFetchingNewerMessages:) name: kCTMFailedFetchingNewerMessages object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedFetchingOlderMessages:) name:kCTMFailedFetchingOlderMessages object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedFetchingOlderMessages:) name:kCTMFinishedFetchingOlderMessages object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedFetchingNewerMessages:) name:kCTMFinishedFetchingNewerMessages object:nil];
}




#pragma mark - notifications for fetching of messages from archive

-(void) failedFetchingNewerMessages:(NSNotification*) notification {
    NSString *cont = [[notification userInfo] valueForKey:kCTMKeyMessageContact];
    NSLog(@"failedFetchingNewerMessages contact: %@", cont);
    
    if ([cont isEqualToString:[self.dataSource getContact]]) {
        __weak AMBubbleTableViewController *weakSelf = self;
        
        if(![NSThread isMainThread]){
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [weakSelf.tableView.infiniteScrollingView stopAnimating];
                               //                               UIView *wrapperView = [[UIView alloc] initWithFrame:loadFooterView.frame];
                               //                               [wrapperView addSubview:loadFooterView];
                               //                               [weakSelf.tableView setTableFooterView:wrapperView];
                               [weakSelf.tableView setTableFooterView:self.footerErrorLabel];
                               
                               [UIView setAnimationsEnabled:NO];
                               [weakSelf.tableView beginUpdates];
                               [weakSelf.tableView endUpdates];
                               [UIView setAnimationsEnabled:YES];
                           });
        }else{
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            //            UIView *wrapperView = [[UIView alloc] initWithFrame:loadFooterView.frame];
            //            [wrapperView addSubview:loadFooterView];
            //            [weakSelf.tableView setTableFooterView:wrapperView];
            [weakSelf.tableView setTableFooterView:self.footerErrorLabel];
            
            [UIView setAnimationsEnabled:NO];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView endUpdates];
            [UIView setAnimationsEnabled:YES];
        }
    }
}

-(void) failedFetchingOlderMessages:(NSNotification*) notification {
    NSString *cont = [[notification userInfo] valueForKey:kCTMKeyMessageContact];
    NSLog(@"failedFetchingOlderMessages contact: %@", cont);
    
    if ([cont isEqualToString:[self.dataSource getContact]]) {
        __weak AMBubbleTableViewController *weakSelf = self;
        
        if(![NSThread isMainThread]){
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [weakSelf.tableView.pullToRefreshView stopAnimating];
                               //                               UIView *wrapperView = [[UIView alloc] initWithFrame:loadHeaderView.frame];
                               //                               [wrapperView addSubview:loadHeaderView];
                               //                               [weakSelf.tableView setTableHeaderView:wrapperView];
                               [weakSelf.tableView setTableHeaderView:self.headerErrorLabel];
                               
                               [UIView setAnimationsEnabled:NO];
                               [weakSelf.tableView beginUpdates];
                               [weakSelf.tableView endUpdates];
                               [UIView setAnimationsEnabled:YES];
                           });
        }else{
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            //            UIView *wrapperView = [[UIView alloc] initWithFrame:loadHeaderView.frame];
            //            [wrapperView addSubview:loadHeaderView];
            //            [weakSelf.tableView setTableHeaderView:wrapperView];
            [weakSelf.tableView setTableHeaderView:self.headerErrorLabel];
            
            [UIView setAnimationsEnabled:NO];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView endUpdates];
            [UIView setAnimationsEnabled:YES];
        }
    }
}

-(void) finishedFetchingNewerMessages:(NSNotification*) notification {
    
    NSString *cont = [[notification userInfo] valueForKey:kCTMKeyMessageContact];
    NSLog(@"finishedFetchingNewerMessages contact: %@", cont);
    NSLog(@"tableview 1 %@", self.tableView);
    NSLog(@"tableview 1 contentinset %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
    if ([cont isEqualToString:[self.dataSource getContact]]) {
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            __weak AMBubbleTableViewController *weakSelf = self;
            
            
            if(![NSThread isMainThread]){
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   [weakSelf.tableView.infiniteScrollingView stopAnimating];
                                   [weakSelf.tableView setTableFooterView:nil];
                                       NSLog(@"tableview 2 %@", self.tableView);
                                     NSLog(@"tableview 2 contentinset %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
                                   [UIView setAnimationsEnabled:NO];
                                   [weakSelf.tableView beginUpdates];
                                   [weakSelf.tableView endUpdates];
                                   [UIView setAnimationsEnabled:YES];
                               });
            }else{
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                [weakSelf.tableView setTableFooterView:nil];
                
                NSLog(@"tableview 2 %@", self.tableView);
                NSLog(@"tableview 2 contentinset %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
                
                [UIView setAnimationsEnabled:NO];
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView endUpdates];
                [UIView setAnimationsEnabled:YES];
            }
        });
    }
}

-(void) finishedFetchingOlderMessages:(NSNotification*) notification {
    NSString *cont = [[notification userInfo] valueForKey:kCTMKeyMessageContact];
    NSLog(@"finishedFetchingOlderMessages contact: %@", cont);
    
    if ([cont isEqualToString:[self.dataSource getContact]]) {
        
        __weak AMBubbleTableViewController *weakSelf = self;
        
        if(![NSThread isMainThread]){
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [weakSelf.tableView.pullToRefreshView stopAnimating];
                               [weakSelf.tableView setTableHeaderView:nil];
                               
                               
                               [UIView setAnimationsEnabled:NO];
                               [weakSelf.tableView beginUpdates];
                               [weakSelf.tableView endUpdates];
                               [UIView setAnimationsEnabled:YES];
                           });
        }else{
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            [weakSelf.tableView setTableHeaderView:nil];
            
            
            [UIView setAnimationsEnabled:NO];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView endUpdates];
            [UIView setAnimationsEnabled:YES];
        }
        
    }
}

-(void)headerErrorLabelTapped {
    NSLog(@"headerErrorLabelTapped");
    [self.tableView triggerPullToRefresh];
}

-(void)footerErrorLabelTapped {
    [self.tableView triggerInfiniteScrolling];
}

- (void)refreshRowsAtTop {
    NSLog(@"refreshRowsAtTop");
    __weak AMBubbleTableViewController *weakSelf = self;
    weakSelf.tableView.tableHeaderView = nil;
    
}

- (void)refreshRowsAtBottom {
    NSLog(@"refreshRowsAtBottom");
    __weak AMBubbleTableViewController *weakSelf = self;
    weakSelf.tableView.tableFooterView = nil;
    [weakSelf.tableView.infiniteScrollingView startAnimating];
    
    //    int64_t delayInSeconds = 2.0;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //
    //        [weakSelf.tableView.infiniteScrollingView stopAnimating];
    //    });
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataSource numberOfSections];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *messageType = [self.dataSource messageTypeForRowAtIndexPath:indexPath];
    if ([messageType intValue] == MessageTypeVoice) {
        
        NSString* cellIdentifier = [NSString stringWithFormat:@"VoiceMessageCell_%d_%d", [[self.dataSource fromForRowAtIndexPath:indexPath] intValue], [[self.dataSource messageStatusForRowAtIndexPath:indexPath] intValue]];
        //NSString* cellIdentifier = @"VoiceMessageCell";
        
        NSLog(@"cellIdentifier: %@", cellIdentifier);
        VoiceMessageCell *cell = nil;
        
        NSDate* date = [self.dataSource timestampForRowAtIndexPath:indexPath];
        int from = [[self.dataSource fromForRowAtIndexPath:indexPath] intValue];
        
        cell = (VoiceMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            //            NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DeleteMessageNoPhotoCell" owner:self options:nil];
            //            for (id currentObject in topLevelObjects) {
            //                if ([currentObject isKindOfClass:[UITableViewCell class]]) {
            //                    cell = (DeleteMessageNoPhotoCell *)currentObject;
            //                    break;
            //                }
            //            }
            cell = [[VoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            //to remove outlines in grouped table view
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            
            
            // iPad cells are set by default to 320 pixels, this fixes the quirk
            cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x,
                                                cell.contentView.frame.origin.y,
                                                self.tableView.frame.size.width,
                                                cell.contentView.frame.size.height);
            
            [cell setupWithType:from];
        }
        
        //time
        [self.dateFormatter setDateFormat:@"h:mm a"];                  // 1:23 PM
        NSString *stringDate = [self.dateFormatter stringFromDate:date];
        
        [cell.timeLabel setText:stringDate];
        
        cell.status = [self.dataSource messageStatusForRowAtIndexPath:indexPath];
        
        if ([cell.status intValue] == MessageStatusSending) {
            NSLog(@"cell status sending");
        }
        else if ([cell.status intValue] == MessageStatusSent) {
            NSLog(@"cell status sent");
        }
        else if ([cell.status intValue] == MessageStatusUploading) {
            NSLog(@"cell status UPLOADING");
        }
        
        NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
        
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSString *localPath = [json objectForKey:kCTMVoiceLocalPath];
        NSString *remoteUrl =[json objectForKey:kCTMVoiceRemoteUrl];
        NSString *duration =[json objectForKey:kCTMVoiceDuration];
        if (localPath){
            cell.localPath = localPath;
        }
        else {
            cell.localPath = nil;
        }
        
        if (remoteUrl){
            cell.remoteUrl = remoteUrl;
        }
        else {
            cell.remoteUrl = nil;
        }
        
        NSLog(@"=== duration here:%@", duration);
        
        //JJRG: regular scenario wherein there is a receipt and json was updated and duration came from backend.
        if(duration){
            cell.fileDuration = duration;
        }else{
            //JJRG: this is for scenario that the message wasn't sent however there is a file somewhere
            if(localPath != nil && [localPath length]>0){
                AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:localPath] options:nil];
                CMTime audioDuration = audioAsset.duration;
                float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
                cell.fileDuration = [NSString stringWithFormat:@"%d", (int) ceilf(audioDurationSeconds) ];
                [cell.durationLabel setText:((cell.fileDuration.intValue > 30)? @"0:30" : cell.fileDuration)];
            }else{
                [cell.durationLabel setText:@""];
            }
        }
        
        NSString *refId = [self.dataSource refIdForRowAtIndexPath:indexPath];
        cell.refId = refId;
        
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        if ([self downloadingRefIdsContainsRefId:refId]) {
            [cell setIsDownloading:YES];
        }
        else if([indexPath isEqual: playingIndexPath] && [audioPlayer isPlaying]){
            [cell setIsPlaying:YES];
            [cell updateSliderToValue:audioPlayer.currentTime withMaxValue:audioPlayer.duration];
        }
        else if ([indexPath isEqual: playingIndexPath] && ![audioPlayer isPlaying]){
            [cell setIsPlaying:NO];
            [cell updateSliderToValue:audioPlayer.currentTime withMaxValue:audioPlayer.duration];
        }
        else {
            [cell setIsPlaying:NO];
        }
        
        // NSString *refId =  [self.dataSource refIdForRowAtIndexPath:indexPath];
        
        if ([self sentRefIDsToAnimateContainsRefId:refId]){
            [cell showSentStatusAnimated:NO];
        }
        else if ([self timeRefIDsToAnimateContainsRefId:refId]){
            [cell showTimeAnimated:NO];
        }
        else {
            if (shouldShowTime){
                [cell showTimeAnimated:NO];
            }
            else {
                [cell hideTimeAnimated:NO];
            }
        }
        
        return cell;
    }else if ([messageType intValue]== MessageTypeAction){
        NSString* cellIdentifier = @"GroupActionCell";
        //NSString* cellIdentifier = @"VoiceMessageCell";
        
        NSLog(@"cellIdentifier: %@", cellIdentifier);
        GroupActionCell *cell = nil;
        
        //        NSDate* date = [self.dataSource timestampForRowAtIndexPath:indexPath];
        //        int from = [[self.dataSource fromForRowAtIndexPath:indexPath] intValue];
        
        cell = (GroupActionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil){
            NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupActionCell" owner:self options:nil];
            for (id currentObject in topLevelObjects) {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                    cell = (GroupActionCell *)currentObject;
                    break;
                }
            }
            //              cell = [[GroupActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        
        
        NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
        
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSString *actionType = [json objectForKey:kCTMGroupAction];
        NSString *groupContact =[json objectForKey:kCTMGroupContact];
        
        
        NSLog(@"Group Action Type:%@", actionType);
        NSLog(@"Group Action Group Contact:%@", groupContact);
        
        BOOL isJoined = [actionType isEqualToString:@"joined"];
//        if([actionType intValue]==MessageActionJoined){
//            isJoined = YES;
//        }else{
//            isJoined = NO;
//
//        }

        
//        [cell setName:[NameCacheUtil getGroupContactNamesString:groupContact] isJoined:isJoined];
        [cell setGroupEventLabel:[NameCacheUtil getGroupEventString:groupContact isJoined:isJoined] isJoined:isJoined];

        
        return cell;
        
        
    }
    else {
        //NSLog(@"SMS!");
        
        AMBubbleCellType type = [self.dataSource cellTypeForRowAtIndexPath:indexPath];
        
        NSString* cellID = [NSString stringWithFormat:@"cell_%d", type];
        NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
        NSDate* date = [self.dataSource timestampForRowAtIndexPath:indexPath];
        AMBubbleTableCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        
        NSNumber *status = [self.dataSource messageStatusForRowAtIndexPath:indexPath];
        UIImage* avatar;
        UIColor* color;
        
        if ([self.dataSource respondsToSelector:@selector(usernameColorForRowAtIndexPath:)]) {
            color = [self.dataSource usernameColorForRowAtIndexPath:indexPath];
        }
        if ([self.dataSource respondsToSelector:@selector(avatarForRowAtIndexPath:)]) {
            avatar = [self.dataSource avatarForRowAtIndexPath:indexPath];
        }
        
        
        if (cell == nil) {
            cell = [[AMBubbleTableCell alloc] initWithOptions:self.options
                                              reuseIdentifier:cellID isGroup:self.isGroup];
            
            cell.delegate = self;
            
            //to remove outlines in grouped table view
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            
            
            // iPad cells are set by default to 320 pixels, this fixes the quirk
            cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x,
                                                cell.contentView.frame.origin.y,
                                                self.tableView.frame.size.width,
                                                cell.contentView.frame.size.height);
        }
        
        // Used by the gesture recognizer
        cell.indexPath = indexPath;
        
        cell.fromType = [[self.dataSource fromForRowAtIndexPath:indexPath] intValue];
        
        NSString* stringDate;
        if (type == AMBubbleCellTimestamp) {
            //[self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];	// Jan 1, 2000
            //[self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];	// 1:23 PM
            
            [self.dateFormatter setDateFormat:@"M/d/yyyy HH:mm"];					// 13:23
            
            stringDate = [self.dateFormatter stringFromDate:date];
            
            @try {
                [cell setupCellWithType:type
                              withWidth:self.tableView.frame.size.width
                              andParams:@{ @"date": stringDate}];
                
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
        } else {
            //[self.dateFormatter setDateFormat:@"M'/'d'/'yy' 'HH':'mm"];     // 11/26/13 23:21
            [self.dateFormatter setDateFormat:@"h:mm a"];                  // 1:23 PM
            //[self.dateFormatter setDateFormat:@"HH:mm"];					// 13:23
            NSString* username;
            if ([self.dataSource respondsToSelector:@selector(usernameForRowAtIndexPath:)]) {
                username = [self.dataSource usernameForRowAtIndexPath:indexPath];
            }
            
            
            stringDate = [self.dateFormatter stringFromDate:date];
            
            @try {
                if(self.isGroup && cell.fromType == MessageFromContact){
                    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog();
                    NSString *groupMessage = [json objectForKey:KCTMMessageBody];
                    NSString *groupContact =[json objectForKey:kCTMGroupContact];
                    
                    
                    NSDictionary *nameCache = [NameCacheUtil getContactDetails:groupContact];
                    NSLog(@"isGorupMessage: %@ %@", groupContact, json);
                    [cell setupCellWithType:type
                                  withWidth:self.tableView.frame.size.width
                                  andParams:@{
                                              @"text": groupMessage,
                                              @"date": stringDate,
                                              @"index": @(indexPath.row),
                                              @"username": (username ? username : @""),
                                              @"avatar": [nameCache objectForKey:@"photoURL"],
                                              @"color": (color ? color: @""),
                                              @"status": (status ? status: @""),
                                              @"name" : [nameCache objectForKey:@"displayName"]
                                              }];
                }else{
                    [cell setupCellWithType:type
                                  withWidth:self.tableView.frame.size.width
                                  andParams:@{
                                              @"text": text,
                                              @"date": stringDate,
                                              @"index": @(indexPath.row),
                                              @"username": (username ? username : @""),
                                              @"avatar": (avatar ? avatar: @""),
                                              @"color": (color ? color: @""),
                                              @"status": (status ? status: @"")
                                              }];
                }
            }
            @catch (NSException *exception) {
                // NSLog(@"exception encountered: %@", exception);
            }
            @finally {
                //NSLog(@"finally in table bubble view");
            }
        }
        NSString *refId =  [self.dataSource refIdForRowAtIndexPath:indexPath];
        
        if ([self sentRefIDsToAnimateContainsRefId:refId]){
            [cell showSentStatusAnimated:NO];
        }
        else if ([self timeRefIDsToAnimateContainsRefId:refId]){
            [cell showTimeAnimated:NO];
        }
        else {
            if (shouldShowTime){
                [cell showTimeAnimated:NO];
            }
            else {
                [cell hideTimeAnimated:NO];
            }
        }
        
        
        return cell;
        
    }
    
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[self.dataSource sections] count ]> 0){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kHeightSectionHeader)];
        
        //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, tableView.frame.size.width, 21)];
        UILabel *label = [[UILabel alloc] init];
        [label setFont:[ChikkaFont smallFont]];
        [label setTextColor:[ChikkaColor grayColor]];
        label.backgroundColor = [UIColor clearColor];
        
        //id <NSFetchedResultsSectionInfo> sectionInfo = [[self.allContactsFRC sections] objectAtIndex:section];
        NSString *title = [self tableView:tableView titleForHeaderInSection:section];
        
        //[label setText:[sectionInfo name]];
        [label setText:title];
        [view addSubview:label];
        [view setBackgroundColor:[UIColor clearColor]];
        
        
        // Configure the cell to show the message in a bubble. Layout message cell & its subviews.
        CGSize sizeText = [title sizeWithFont:label.font
                            constrainedToSize:CGSizeMake(view.frame.size.width, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
        
        [label setFrame:CGRectMake((view.frame.size.width - sizeText.width)/2, (view.frame.size.height - sizeText.height)/2, sizeText.width, sizeText.height)];
        
        return view;
        
    }
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kHeightSectionHeader)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightSectionHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    id <NSFetchedResultsSectionInfo> theSection = [[self.dataSource sections] objectAtIndex:section];
    
    /*
     Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
     To display the section title, convert the year and month components to a string representation.
     */
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MMMM d, YYYY" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:formatTemplate];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    //    NSLog(@"numeric section: %ld", (long)numericSection);
    NSInteger year = numericSection / 1000000;
    NSInteger month = (numericSection - (year * 1000000)) / 1000;
    NSInteger day = numericSection - (year * 1000000) - (month * 1000);
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    //NSLog(@"date: %@", date);
    
    //create today
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    
    NSString *titleString = nil;
    
    if([todayComponents day] == [dateComponents day] &&
       [todayComponents month] == [dateComponents month] &&
       [todayComponents year] == [dateComponents year]) {
        //date today
        titleString = @"Today";
    }
    else if(([todayComponents day]-1) == [dateComponents day] &&
            [todayComponents month] == [dateComponents month] &&
            [todayComponents year] == [dateComponents year]) {
        //date yesterday
        titleString = @"Yesterday";
    }
    else {
        titleString = [formatter stringFromDate:date];
    }
    
    
    return titleString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"didSelectRowAtIndexPath");
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    if ([self.delegate respondsToSelector:@selector(swipedCellAtIndexPath:withFrame:andDirection:)]) {
        [self.delegate swipedCellAtIndexPath:[NSIndexPath indexPathForRow:sender.view.tag inSection:0] withFrame:sender.view.frame andDirection:sender.direction];
    }
}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan){
        
        longPressCell = (AMBubbleTableCell*) sender.view;
        longPressCell.isSelected = YES;
        [self.tableView reloadData];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(AMBubbleTableCell *)longPressCell];
        NSNumber *from = [self.dataSource fromForRowAtIndexPath:indexPath];
        
        if ([from intValue] == MessageFromContact){
            
            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
            UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forwardMessage:)];
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:[NSArray arrayWithObjects:copy, forward, delete, nil]];
            //[menu setTargetRect:longPressCell.imageBackground.frame inView:sender.view];
            [menu setTargetRect:longPressCell.bubbleView.frame inView:sender.view];
            [menu setMenuVisible:YES animated:YES];
            
        }else {
            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
            UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forwardMessage:)];
            UIMenuItem *resend = [[UIMenuItem alloc] initWithTitle:@"Resend" action:@selector(resendMessage:)];
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:[NSArray arrayWithObjects:copy, forward, resend, delete, nil]];
            //[menu setTargetRect:longPressCell.imageBackground.frame inView:sender.view];
            [menu setTargetRect:longPressCell.bubbleView.frame inView:sender.view];
            [menu setMenuVisible:YES animated:YES];
            
        }
    }else{
        if (sender.state == UIGestureRecognizerStateEnded){}
    }
    
}


- (void)copyMessage:(id)sender {
    //NSLog(@"copy message");
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:kGOOGLE_SCREEN_MESSAGE_THREAD];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGOOGLE_CATEGORY_UX
                                                          action:kGOOGLE_EVENTS_COPY_SMS
                                                           label:kGOOGLE_EVENTS_COPY_SMS
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    
    if (longPressIndexPath!=nil){
        @try {
            NSString *copyStringverse = [self.dataSource textForRowAtIndexPath:longPressIndexPath];
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:copyStringverse];
        }
        @catch (NSException *exception) {
            NSLog(@"exception in copyMessage: %@", exception);
        }
        @finally {
            
        }
    }
}

- (void)forwardMessage:(id)sender {
    NSString *eventName;
    
    NSNumber *messageType = [self.dataSource messageTypeForRowAtIndexPath:longPressIndexPath];
    NSString *body = [self.dataSource textForRowAtIndexPath:longPressIndexPath];
    NSString *refId =[self.dataSource refIdForRowAtIndexPath:longPressIndexPath];
    
    if ([messageType intValue] == MessageTypeVoice) {
        [self.delegate forwardVoiceMessageWithBody:body andRefId:refId];
        eventName = kGOOGLE_EVENTS_FORWARD_VM;
    }
    else {
        [self.delegate forwardText:body];
        eventName = kGOOGLE_EVENTS_FORWARD_SMS;
        
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:kGOOGLE_SCREEN_MESSAGE_THREAD];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGOOGLE_CATEGORY_UX
                                                          action:eventName
                                                           label:eventName
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)moreMessage:(id)sender {
    NSString *resend = @"Resend";
    NSString *delete = @"Delete";
    NSString *share = @"Share";
    NSString *cancelTitle = @"Cancel";
    
    moreActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:cancelTitle
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:resend, delete, share, nil];
    
    [moreActionSheet showInView:self.parentViewController.view];
    
}

-(void)resendMessage:(id)sender{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:kGOOGLE_SCREEN_MESSAGE_THREAD];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGOOGLE_CATEGORY_UX
                                                          action:kGOOGLE_EVENTS_RETRY_SENDING_VIA_CONTEXT_MENU
                                                           label:kGOOGLE_EVENTS_RETRY_SENDING_VIA_CONTEXT_MENU
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    NSNumber *messageType = [self.dataSource messageTypeForRowAtIndexPath:longPressIndexPath];
    NSNumber *status = [self.dataSource messageStatusForRowAtIndexPath:longPressIndexPath];
    
    if ([messageType intValue] == MessageTypeVoice) {
        if ([status intValue] == MessageStatusFailed || [status intValue] == MessageStatusFailedCredits){
            NSString *refId = [self.dataSource refIdForRowAtIndexPath:longPressIndexPath];
            [self.delegate resendVoiceMessageWithRefId:refId];
        }else {
            NSString *body = [self.dataSource textForRowAtIndexPath:longPressIndexPath];
            NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *forwardUrl = [json objectForKey:kCTMVoiceForwardUrl];
            NSString *localPath = [json objectForKey:kCTMVoiceLocalPath];
            NSString *remoteUrl = [json objectForKey:kCTMVoiceRemoteUrl];
            NSString *duration = [json objectForKey:kCTMVoiceDuration];
            [self.delegate didSendVoiceMessageWithForwardUrl:forwardUrl andRemoteUrl:remoteUrl andLocalPath:localPath andDuration:duration];
        }
    }
    else {
        
        if ([status intValue] == MessageStatusFailed || [status intValue] == MessageStatusFailedCredits){
            NSString *refId = [self.dataSource refIdForRowAtIndexPath:longPressIndexPath];
            [self.delegate resendTextForRefId:refId];
        }else if ([status intValue] == MessageStatusSending || [status intValue] == MessageStatusSent || [status intValue] == MessageStatusSentViaSMS){
            NSString *body = [self.dataSource textForRowAtIndexPath:longPressIndexPath];
            [self.delegate didSendText:body];
        }
    }
    
    
}

-(void)deleteMessage:(id)sender{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:kGOOGLE_SCREEN_MESSAGE_THREAD];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGOOGLE_CATEGORY_UX
                                                          action:kGOOGLE_EVENTS_DELETE_MESSAGE_VIA_CONTEXT_MENU
                                                           label:kGOOGLE_EVENTS_DELETE_MESSAGE_VIA_CONTEXT_MENU
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete this message?"];
    
    alertViewDelete = [[UIAlertView alloc] initWithTitle:@""
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles: @"Delete", nil];
    [alertViewDelete show];
}


-(void)shareMessage:(id)sender{
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)deselectLongPressCell {
    NSNumber *messageType = [self.dataSource messageTypeForRowAtIndexPath:longPressIndexPath];
    if ([messageType intValue] == MessageTypeVoice) {
        AMBubbleTableCell *cell = (AMBubbleTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:longPressIndexPath.row inSection:longPressIndexPath.section]];
        [cell setIsSelected:NO];
    }
    else {
        VoiceMessageCell *cell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:longPressIndexPath.row inSection:   longPressIndexPath.section]];
        [cell setIsSelected:NO];
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *messageType = [self.dataSource messageTypeForRowAtIndexPath:indexPath];
    if ([messageType intValue] == MessageTypeVoice) {
        //        return 108;
        //        return 70;
        return 64;
    } else if ([messageType intValue] == MessageTypeAction) {
//        return 31;
        
        NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
        
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSString *actionType = [json objectForKey:kCTMGroupAction];
        NSString *groupContact =[json objectForKey:kCTMGroupContact];
        
         BOOL isJoined = [actionType isEqualToString:@"joined"];
//        if([actionType intValue]==MessageActionJoined){
//            isJoined = YES;
//        }else{
//            isJoined = NO;
//            
//        }
        
        NSString *str = [NameCacheUtil getGroupEventString:groupContact isJoined:isJoined];
        
        CGSize sizeText = [str sizeWithFont:kActionMessageFont
                               constrainedToSize:CGSizeMake(kActionMaxTextWidth, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
        return sizeText.height + 18;
        
    }
    else {
        NSString* text;
        
        
        
        if(self.isGroup && [[self.dataSource fromForRowAtIndexPath:indexPath] intValue]==MessageFromContact){
            NSData *data = [[self.dataSource textForRowAtIndexPath:indexPath] dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            text = [json objectForKey:KCTMMessageBody];
        }else{
            text = [self.dataSource textForRowAtIndexPath:indexPath];
        }
        //        // Set MessageCell height.
        CGSize size = [text sizeWithFont:[ChikkaFont mediumFont]
                       constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
        
        
        //return (size.height + 58); //size + padding
        //        return (size.height + 38.0f); //size + padding
        return (size.height + 36.0f); //size + padding
    }
    
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self showTimeInTableView];
    [self startTimer];
}


#pragma mark - UIMenuController handlers

-(void)didHideEditMenu:(NSNotification *)notification
{
    [self deselectLongPressCell];
}


#pragma mark - Keyboard Handlers

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    [self.tableView setShowsInfiniteScrolling:NO];
    
    mustShowAd = NO;
    // Get the height of the keyboard.
    //it is necessary to check whether in landscape or portrait mode--keyboard always gets size in portrait mode
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        keyboardHeight= [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.width;
    }
    else {
        keyboardHeight= [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    }
    [self.messageInputView setMaxHeightforMessageInput:(self.view.frame.size.height - keyboardHeight - 20)];
    [self.recordingView hideInTargetView:self.view];
    
    
//  NOTE: COMMENTED THIS OUT MUNA DEC 3 2014
//    [self resizeViewForRecording];

    
    //    [self resizeView:notification];
    //    if (![self.recordingView isShown]){
    [self resizeView:notification];
    [self scrollToBottomAnimated:YES];
    //    }
    
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    
    
    
    keyboardHeight  = 0;
    
    if (![self.recordingView isShown]){
        mustShowAd = YES;
        [self resizeView:notification];
        [self scrollToBottomAnimated:YES];
        
    }else{
        mustShowAd = NO;
    }
    
    
}


-(void)handleKeyboardDidHide:(NSNotification *)notification{
    
    [self.tableView setShowsInfiniteScrolling:YES];
    
    ////    keyboardHeight  = 0;
    //
    //    if (![self.recordingView isShown]){
    //        mustShowAd = YES;
    //        [self resizeView:notification];
    //    }else{
    ////        mustShowAd = NO;
    //    }
}


- (void)handleKeyboardDidShow:(NSNotification *)notification
{
    [self.messageInputView showMicrophoneButton];
    
    
}


- (void)resizeView:(NSNotification*)notification
{
    //NSLog(@"resizeView with notif: %@", notification);
    [self.messageInputView adjustViewHeight];
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat viewHeight = (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? MIN(self.view.frame.size.width,self.view.frame.size.height) : MAX(self.view.frame.size.width,self.view.frame.size.height));
    CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    CGFloat diff = keyboardY - viewHeight;
    
    // This check prevents an issue when the view is inside a UITabBarController
    if (diff > 0) {
        double fraction = diff/keyboardY;
        duration *= (1-fraction);
        keyboardY = viewHeight;
    }
    
    // Thanks to Raja Baz (@raja-baz) for the delay's animation fix.
    CGFloat delay = 0.0f;
    CGRect beginRect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    diff = beginRect.origin.y - viewHeight;
    if (diff > 0) {
        double fraction = diff/beginRect.origin.y;
        delay = duration * fraction;
        duration -= delay;
    }
    
    void (^completition)(void) = ^{
        CGFloat inputViewFrameY = keyboardY - self.messageInputView.frame.size.height -(mustShowAd && hasAdLoaded ? bannerView_.frame.size.height : 0);
        //		if(mustShowAd && hasAdLoaded){
        //            inputViewFrameY = inputViewFrameY - bannerView_.frame.size.height;
        //        }
        self.messageInputView.frame = CGRectMake(self.messageInputView.frame.origin.x,
                                                 inputViewFrameY,
                                                 self.messageInputView.frame.size.width,
                                                 self.messageInputView.frame.size.height);
        
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                               0.0f,
                                               viewHeight - self.messageInputView.frame.origin.y,
                                               0.0f);
        
        
        
        NSLog(@"INSETS BAM!! %@", NSStringFromUIEdgeInsets(insets));
        NSLog(@"viewHeight: %f", viewHeight);
        NSLog(@"tableview: %@", self.tableView);
        NSLog(@"message input %@",self.messageInputView);
        NSLog(@"ads banner frame %@", bannerView_);
        
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
        
        
        NSLog(@"tableview contentinset %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
    };
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:500.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:completition
                         completion:nil];
    } else {
        [UIView animateWithDuration:duration
                              delay:delay
                            options:UIViewAnimationOptionCurveLinear
                         animations:completition
                         completion:nil];
    }
}

-(void)resizeViewForRecording {
    NSLog(@"resizeViewForRecording");
    
    //    if (keyboardHeight>0) {
    //        return;
    //    }
    
    
    CGFloat viewHeight = (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? MIN(self.view.frame.size.width,self.view.frame.size.height) : MAX(self.view.frame.size.width,self.view.frame.size.height));
    CGFloat recordHeight = 0.0f;
    // if ([self.recordingView isShown]){
    //    recordHeight = [self.recordingView height];
    // }
    if(keyboardHeight == 0){
        recordHeight = [self.recordingView height];
    }else{
        recordHeight = keyboardHeight;
    }
    
    NSLog(@"mustShowAd %@", mustShowAd ? @"YES": @"NO");
    CGFloat inputViewFrameY = viewHeight - self.messageInputView.frame.size.height - recordHeight -(mustShowAd && hasAdLoaded ? bannerView_.frame.size.height : 0);
    //    if(mustShowAd){
    //        inputViewFrameY = inputViewFrameY - bannerView_.frame.size.height;
    //    }
    //
    NSLog(@"input view frame Y = %f", inputViewFrameY);
    NSLog(@"record height = %f", recordHeight);
    
    [self.messageInputView setFrame:CGRectMake(self.messageInputView.frame.origin.x,
                                               inputViewFrameY,
                                               self.messageInputView.frame.size.width,
                                               self.messageInputView.frame.size.height)];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                           0.0f,
                                           viewHeight - self.messageInputView.frame.origin.y,
                                           0.0f);
    
    
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    if ([self.recordingView isShown]){
        [self scrollToBottomAnimated:YES];
    }
    
    
}

#pragma mark - Tap Gesture Recognizer

- (void)dismissKeyboardAndShowTime:(UIGestureRecognizer*)gesture
{
    NSLog(@"dismisskeyboardandshowtime");
    mustShowAd = YES;
    
    
    if ([self.recordingView isShown]){
        
        //[self.recordingView hideInView:self.view];
        [self.recordingView hideInTargetView:self.view];
        [self resizeViewForRecording];
    }
    
    //[self.messageInputView showMicrophoneButton];
    if ([self.recordingView hasRecording]) {
        [self.messageInputView showAlreadyExisting];
    }
    [self.messageInputView resignFirstResponder];
    [self showTimeInTableView];
    [self startTimer];
}



#pragma mark - Other functions

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger section = [self.dataSource numberOfSections] - 1;
    if (section >=0){
        NSInteger bottomRow = [self.dataSource numberOfRowsInSection:section] - 1;
        if (bottomRow >= 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:section];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)reloadTableScrollingToBottom:(BOOL)scroll
{
    [self.tableView reloadData];
    [self scrollToBottomAnimated:scroll];
}



- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
    }
    return _dateFormatter;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
    [self resizeViewForRecording];
}


#pragma mark - MessageInputDelegate methods

- (BOOL)messageInputShouldSendWithText:(NSString*)text
{
    if ([text length]>0 || [self.recordingView hasRecording]){
        return YES;
    }
    else {
        return NO;
    }
}

- (void)messageInputSendPressedWithText:(NSString*)text
{
    if ([self.recordingView hasRecording]){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker set:kGAIScreenName value:kGOOGLE_SCREEN_MESSAGE_THREAD];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGOOGLE_CATEGORY_UX
                                                              action:kGOOGLE_EVENTS_MESSAGE_REPLY_VM
                                                               label:kGOOGLE_EVENTS_MESSAGE_REPLY_VM
                                                               value:nil] build]];
        
        [self.recordingView sendButtonPressed:nil];
    }
    else {
        [self.delegate didSendText:text];
    }
    
    
}

- (void) messageInputViewDidResizeWithHeight:(CGFloat) height
{
    //NSLog(@"messageInputViewDidResizeWithHeight: %f", height);
    //change table view frame here?
    
    //NSLog(@"inset: %f", height+keyboardHeight);
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                           0.0f,
                                           height + keyboardHeight,
                                           0.0f);
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self scrollToBottomAnimated:YES];
}

- (void) messageInputMicrophonePressed {
    NSLog(@"micropressed in bubble view");
    NSLog(@"mustShowAd %@", mustShowAd ? @"YES": @"NO");
    
    
    [self.recordingView showInTargetView:self.view];
    mustShowAd = NO;
    [self resizeViewForRecording];
    [self.messageInputView.textView setEditable:NO];
    [self.messageInputView resignFirstResponder];
}

- (void) messageInputTextViewPressed {
    mustShowAd = NO;
    if ([self.recordingView isRecording]){
        [ChikkaAlertView showAlertViewWithPromptButtonTitle:TITLE_OK andMessage:PROMPT_RECORDING_CANCEL_OVERRIDE andDelegate:self];
    }else {
        [self.messageInputView.textView setEditable:YES];
        [self.recordingView cancelRecording];
        [self.messageInputView becomeFirstResponder];
    }
}

-(void) messageInputCancelPressed {
    if ([self.recordingView isRecording]){
        [ChikkaAlertView showAlertViewWithPromptButtonTitle:TITLE_OK andMessage:PROMPT_RECORDING_CANCEL_OVERRIDE andDelegate:self];
    }else {
        mustShowAd = YES;
        
        [self.recordingView hideInTargetView:self.view];
        [self resizeViewForRecording];
        [self.messageInputView.textView setEditable:YES];
    }
}

- (BOOL) messageInputShouldEnableVoice {
    return [self.delegate shouldEnableVoice];
}


#pragma mark - AMBubbleTableCell Delegate methods

-(void)resendButtonPressedForCell:(AMBubbleTableCell *)cell
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:kGOOGLE_SCREEN_MESSAGE_THREAD];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGOOGLE_CATEGORY_UX
                                                          action:kGOOGLE_EVENTS_RETRY_SENDING_VIA_BUTTON
                                                           label:kGOOGLE_EVENTS_RETRY_SENDING_VIA_BUTTON
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    
    //NSLog(@"resendButtonPressedForCell");
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(AMBubbleTableCell *)cell];
    NSString *refId = [self.dataSource refIdForRowAtIndexPath:indexPath];
    
    [self.delegate resendTextForRefId:refId];
}

-(void)labelhasNoURLonTap
{
    [self.messageInputView.textView resignFirstResponder];
    [self showTimeInTableView];
    [self startTimer];
}

-(void)longPressDetectedOnBubbleTableCell:(AMBubbleTableCell *)cell
{
    [cell setIsSelected:YES];
    [self.tableView reloadData];
    
    longPressIndexPath = cell.indexPath;
    
    
    NSNumber *from = [self.dataSource fromForRowAtIndexPath:longPressIndexPath];
    
    if ([from intValue] == MessageFromContact){
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
        UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forwardMessage:)];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:copy, forward, delete, nil]];
        [menu setTargetRect:cell.bubbleView.frame inView:cell];
        [menu setMenuVisible:YES animated:YES];
        
    }else {
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
        UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forwardMessage:)];
        UIMenuItem *resend = [[UIMenuItem alloc] initWithTitle:@"Resend" action:@selector(resendMessage:)];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:copy, forward, resend, delete, nil]];
        [menu setTargetRect:cell.bubbleView.frame inView:cell];
        [menu setMenuVisible:YES animated:YES];
        
    }
    
}

#pragma mark - UIActionsheetdelegate methods


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (actionSheet==moreActionSheet){
        if ([buttonTitle isEqualToString:@"Resend"]){
            
            NSNumber *status = [self.dataSource messageStatusForRowAtIndexPath:longPressIndexPath];
            
            if ([status intValue] == MessageStatusFailed || [status intValue] == MessageStatusFailedCredits){
                NSString *refId = [self.dataSource refIdForRowAtIndexPath:longPressIndexPath];
                [self.delegate resendTextForRefId:refId];
            }else if ([status intValue] == MessageStatusSending || [status intValue] == MessageStatusSent || [status intValue] == MessageStatusSentViaSMS){
                NSString *body = [self.dataSource textForRowAtIndexPath:longPressIndexPath];
                [self.delegate didSendText:body];
            }
        }
        
    }
    
}

#pragma mark - AlertView Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if (alertView == alertViewDelete){
        
        if([title isEqualToString:@"Delete"]){
            NSString *refId = [self.dataSource refIdForRowAtIndexPath:longPressIndexPath];
            [[DataDelegate sharedInstance]deleteMessagesWithArrayOfRefId:[NSArray arrayWithObjects:refId, nil] isSelectAll:NO];
        }
        
    }else{
        if([title isEqualToString:TITLE_OK]){
            [self.recordingView cancelRecording];
            [self.messageInputView.textView setEditable:YES];
            [self.messageInputView becomeFirstResponder];
        }
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[PPLabel class]]){
        return NO;
    }
    
    return YES;
    
}


#pragma mark - RecordingInputDelegate methods


- (void) recordingInputViewWillStartRecording {
    [self stopPlayback];
    
    if (playingIndexPath){
        
        VoiceMessageCell *vmCell;
        vmCell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndexPath.row inSection:playingIndexPath.section]];
        NSLog(@"vmcell to setisplaying NO: %@", vmCell);
        
        if ([vmCell respondsToSelector:@selector(setIsPlaying:)]){
            [vmCell setIsPlaying:NO];
        }
        
        playingIndexPath = nil;
    }
}


-(void) recordingInputViewDidHide {
    [self.messageInputView showMicrophoneButton];
}


-(void) recordingInputViewDidShow {
    [self stopPlayback];
    
    if (playingIndexPath){
        VoiceMessageCell *cell;
        cell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndexPath.row inSection:playingIndexPath.section]];
        if ([cell respondsToSelector:@selector(setIsPlaying:)]){
            [cell setIsPlaying:NO];
        }
        
        playingIndexPath = nil;
    }
    
    [self.messageInputView showCancelButton];
}
-(void) recordingError{
    //  [ChikkaAlertView showAlertViewWithMessage:@"our voice message cannot be saved right now. Please try again later."];
}


- (BOOL) recordingInputViewSendPressedWithForwardUrl:(NSString*)forward andRemoteUrl:(NSString*)remote andLocalPath:(NSString*) local andDuration:(NSString*) duration {
    [self.delegate didSendVoiceMessageWithForwardUrl:forward andRemoteUrl:remote andLocalPath:local andDuration:duration];
    //[self.recordingView hideInTargetView:self.view];
    //[self resizeViewForRecording];
    return YES;
    
}


#pragma mark - AVAudioPlayerDelegate methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //[playerUpdater invalidate];
    [self stopPlayback];
    
    if (playingIndexPath){
        VoiceMessageCell *cell;
        cell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndexPath.row inSection:playingIndexPath.section]];
        if ([cell respondsToSelector:@selector(setIsPlaying:)]){
            [cell setIsPlaying:NO];
        }
        
        playingIndexPath = nil;
    }
    
}

#pragma mark - play/pause avaudioplayer

-(void)startPlaybackForPath:(NSString*)path{
    if (audioPlayer.playing == NO){
        NSURL *soundFileURL = [NSURL fileURLWithPath:path];
        
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:soundFileURL
                       error:&error];
        
        audioPlayer.delegate = self;
        
        if (error){
            NSLog(@"ERROR SETTING UP AUDIO PLAYER. %@", error);
        }
        else{
            //if (playingIndexPath){
            VoiceMessageCell *cell;
            cell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndexPath.row inSection:playingIndexPath.section]];
            [cell setSliderMaxValue: audioPlayer.duration];
            //}
            
            if (playingCurrentTime){
                //[audioPlayer playAtTime:playingCurrentTime];
                [audioPlayer setCurrentTime:playingCurrentTime];
            }
            
            NSLog(@"MAAAAAAAX TIME: %f", audioPlayer.duration);
            
            [audioPlayer play];
            
            playerUpdater = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updatePlaybackTimer:) userInfo:nil repeats:YES];
            
        }
    }
    
    // isPlaying = YES;
}

-(void)pausePlayback{
    if (audioPlayer.playing == YES){
        [playerUpdater invalidate];
        [audioPlayer pause];
        
        playingDuration = audioPlayer.duration;
        playingCurrentTime= audioPlayer.currentTime;
    }
    
    // isPlaying = NO;
}

-(void)stopPlayback{
    if (audioPlayer){
        NSLog(@"stop playback");
        [playerUpdater invalidate];
        [audioPlayer stop];
        
        playingDuration = 30.0f;
        playingCurrentTime = 0.0f;
    }
    
    // isPlaying = NO;
}


-(void)updatePlaybackTimer:(NSTimer*)timer {
    VoiceMessageCell *cell;
    cell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndexPath.row inSection:playingIndexPath.section]];
    [cell updateSliderToValue:audioPlayer.currentTime withMaxValue:audioPlayer.duration];
    
}

#pragma mark - VoiceMessageCellDelegate methods

-(void)playButtonPressedForVoiceMessageCell: (VoiceMessageCell*) cell {
    if ([self.recordingView isRecording]){
        NSLog(@"recording ongoing!!!!! DO NOT PLAY!");
        [cell setIsPlaying:NO];
        return;
    }
    
    
    if (![playingIndexPath isEqual:cell.indexPath]){
        [self stopPlayback];
        
        if (playingIndexPath){
            
            VoiceMessageCell *vmCell;
            vmCell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndexPath.row inSection:playingIndexPath.section]];
            NSLog(@"vmcell to setisplaying NO: %@", vmCell);
            
            if ([cell respondsToSelector:@selector(setIsPlaying:)]){
                [cell setIsPlaying:NO];
            }
        }
        
    }
    else {
        
    }
    
    playingIndexPath = cell.indexPath;
    
    if (cell.localPath) {
        NSLog(@"path exists!");
        NSLog(@"path: %@", cell.localPath);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:cell.localPath]){
            NSLog(@"fileManager says file exists, too! start playback!");
            [cell setIsPlaying:YES];
            [self startPlaybackForPath:cell.localPath];
        }
        
    }else if (cell.remoteUrl && cell.refId){
        [downloadingRefIDs setObject:cell.indexPath forKey:cell.refId];
        NSLog(@"ADDING! downloadingRefIDs: %@", downloadingRefIDs);
        
        [[DataDelegate sharedInstance]downloadVoiceMessage:cell.remoteUrl withRefId:cell.refId];
        toPlayMessageCell = cell;
        [toPlayMessageCell setIsDownloading:YES];
        //[[DataDelegate sharedInstance]downloadVoiceMessage:@"http://10.11.3.59:8888/BOLSHOI%20-%20Away.mp3" withRefId:cell.refId];
        
    }else {
        //no local, no remote! ><
    }
    
    [self.tableView reloadData];
}

-(void)pauseButtonPressedForVoiceMessageCell: (VoiceMessageCell*) cell {
    if (![playingIndexPath isEqual:cell.indexPath]){
        VoiceMessageCell *vmCell;
        vmCell = (VoiceMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndexPath.row inSection:playingIndexPath.section]];
        if ([vmCell respondsToSelector:@selector(setIsPlaying:)]){
            [vmCell setIsPlaying:NO];
        }
        
        
    }
    else {
        NSLog(@"PAUSE currently playing!");
        [self pausePlayback];
    }
    
    
}

-(BOOL)shouldPlayAfterBubbleTapForVoiceMessageCell: (VoiceMessageCell*) cell {
    if ([playingIndexPath isEqual:cell.indexPath] && audioPlayer.isPlaying){
        return NO;
    }
    
    return YES;
    
    
}


-(void)resendButtonPressedForVoiceMessageCell: (VoiceMessageCell*) cell {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:kGOOGLE_SCREEN_MESSAGE_THREAD];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kGOOGLE_CATEGORY_UX
                                                          action:kGOOGLE_EVENTS_RETRY_SENDING_VIA_BUTTON
                                                           label:kGOOGLE_EVENTS_RETRY_SENDING_VIA_BUTTON
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    //    if([cell.indexPath isEqual: playingIndexPath] && [audioPlayer isPlaying]){
    //        [self stopPlayback];
    //        [cell setIsPlaying:NO];
    //        [cell updateSliderToValue:0.0f withMaxValue:audioPlayer.duration];
    //        playingIndexPath = nil;
    //    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(VoiceMessageCell *)cell];
    NSString *refId = [self.dataSource refIdForRowAtIndexPath:indexPath];
    
    //    [self.delegate resendTextForRefId:refId];
    [self.delegate resendVoiceMessageWithRefId:refId];
    
}

-(void)longPressDetectedOnVoiceMessageCell:(VoiceMessageCell *)cell
{
    if([cell.indexPath isEqual: playingIndexPath] && [audioPlayer isPlaying]){
        [self stopPlayback];
        [cell setIsPlaying:NO];
        [cell updateSliderToValue:0.0f withMaxValue:audioPlayer.duration];
        playingIndexPath = nil;
    }
    
    [cell setIsSelected:YES];
    [self.tableView reloadData];
    
    longPressIndexPath = cell.indexPath;
    
    
    NSNumber *from = [self.dataSource fromForRowAtIndexPath:longPressIndexPath];
    
    if ([from intValue] == MessageFromContact){
        UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forwardMessage:)];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:forward, delete, nil]];
        [menu setTargetRect:cell.bubbleView.frame inView:cell];
        [menu setMenuVisible:YES animated:YES];
        
    }else {
        UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forwardMessage:)];
        UIMenuItem *resend = [[UIMenuItem alloc] initWithTitle:@"Resend" action:@selector(resendMessage:)];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:forward, resend, delete, nil]];
        [menu setTargetRect:cell.bubbleView.frame inView:cell];
        [menu setMenuVisible:YES animated:YES];
        
    }
    
    
}

-(void)sliderValueChangedTo: (CGFloat) value forVoiceMessageCell:(VoiceMessageCell *)cell {
    //    if (playingIndexPath == nil) {
    //        NSLog(@"index path nil!");
    //        playingIndexPath = cell.indexPath;
    //    }
    if ((cell.indexPath.row==playingIndexPath.row && cell.indexPath.section==playingIndexPath.section)) {
        NSLog(@"slider value changed for playing cell!");
        audioPlayer.currentTime = value;
        playingCurrentTime = value;
    }
    
}

#pragma mark - Show/Hide Time Label Animation Things

-(void)showTimeInTableView
{
    if (shouldShowTime){
        return;
    }
    else {
        NSString *refid = nil;
        
        for (id cell in [self.tableView visibleCells]) {
            if ([cell isKindOfClass:[VoiceMessageCell class]]) {
                refid = [self.dataSource refIdForRowAtIndexPath:((VoiceMessageCell*)cell).indexPath];
            }
            else if ([cell isKindOfClass:[AMBubbleTableCell class]]) {
                refid = [self.dataSource refIdForRowAtIndexPath:((AMBubbleTableCell*)cell).indexPath];
            }
            
            if (![self sentRefIDsToAnimateContainsRefId:refid] && ![self timeRefIDsToAnimateContainsRefId:refid]) {
                [cell showTimeAnimated:YES];
                
            }
            
        }
        shouldShowTime = YES;
    }
}

-(void)hideTimeInTableView
{
    if (!shouldShowTime){
        return;
    }
    else {
        NSString *refid = nil;
        
        for (id cell in [self.tableView visibleCells]) {
            if ([cell isKindOfClass:[VoiceMessageCell class]]) {
                refid = [self.dataSource refIdForRowAtIndexPath:((VoiceMessageCell*)cell).indexPath];
            }
            else if ([cell isKindOfClass:[AMBubbleTableCell class]]) {
                refid = [self.dataSource refIdForRowAtIndexPath:((AMBubbleTableCell*)cell).indexPath];
            }
            
            if (![self sentRefIDsToAnimateContainsRefId:refid] && ![self timeRefIDsToAnimateContainsRefId:refid]) {
                [cell hideTimeAnimated:YES];
                
            }
        }
        shouldShowTime = NO;
    }
    
}

static const NSTimeInterval TIMER_INTERVAL = 3.0;

- (void)startTimer
{
    //stop timer and restart if it already exists
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                             target:self
                                           selector:@selector(timerHasEnded:)
                                           userInfo:nil
                                            repeats:NO];
    
}

-(void)timerHasEnded: (NSTimer*) timey
{
    
    [self hideTimeInTableView];
    
    [timer invalidate];
    timer = nil;
}

-(void)createTemporarySentStatusTimerForRefID:(NSString*)refId {
    NSLog(@"createTemporarySentStatusTimerForRefID");
    [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                     target:self
                                   selector:@selector(temporarySentStatusTimerHasEnded:)
                                   userInfo:[NSDictionary dictionaryWithObject:refId forKey:kCTMKeyMessageId]
                                    repeats:NO];
    
    
}

-(void)temporarySentStatusTimerHasEnded: (NSTimer*) tempTimer {
    
    NSLog(@"temporaryTimerHasEnded: %@", [tempTimer userInfo]);
    NSDictionary *dict = [tempTimer userInfo];
    NSString *refId = [dict objectForKey:kCTMKeyMessageId];
    NSIndexPath *indexPath = [sentRefIDsToAnimate objectForKey:refId];
    
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //    if (shouldShowTime) {
    //        [cell hideSentStatusAnimated:NO];
    //        [cell showTimeAnimated:NO];
    //    }
    //    else {
    //        [cell hideSentStatusAnimated:YES];
    //    }
    
    [cell hideSentStatusAnimated:NO];
    [cell showTimeAnimated:NO];
    
    
    [self createTemporaryTimeStatusTimerForRefID:refId];
    if(indexPath!= nil){
        [timeRefIDsToAnimate setObject:indexPath forKey:refId];
    }
    [sentRefIDsToAnimate removeObjectForKey:refId];
    
    [tempTimer invalidate];
    tempTimer = nil;
}

-(void)createTemporaryTimeStatusTimerForRefID:(NSString*)refId {
    NSLog(@"createTemporaryTimeStatusTimerForRefID");
    [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                     target:self
                                   selector:@selector(temporaryTimeStatusTimerHasEnded:)
                                   userInfo:[NSDictionary dictionaryWithObject:refId forKey:kCTMKeyMessageId]
                                    repeats:NO];
    
    
}

-(void)temporaryTimeStatusTimerHasEnded: (NSTimer*) tempTimer {
    
    NSLog(@"temporaryTimeStatusTimerHasEnded: %@", [tempTimer userInfo]);
    NSDictionary *dict = [tempTimer userInfo];
    NSString *refId = [dict objectForKey:kCTMKeyMessageId];
    NSIndexPath *indexPath = [timeRefIDsToAnimate objectForKey:refId];
    
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (!shouldShowTime) {
        [cell hideTimeAnimated:YES];
    }
    
    
    
    [timeRefIDsToAnimate removeObjectForKey:refId];
    
    [tempTimer invalidate];
    tempTimer = nil;
}

#pragma mark - other methods

-(BOOL)downloadingRefIdsContainsRefId:(NSString*)refId
{
    
    BOOL refIdSelected = NO;
    
    for (NSString *item in downloadingRefIDs){
        if ([refId isEqualToString:item]){
            //refid already in downloadingRefIds
            refIdSelected = YES;
            break;
        }
        else {
            //refid not yet in downloadingRefIds
            
        }
    }
    
    if (refIdSelected){
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)sentRefIDsToAnimateContainsRefId:(NSString*)refId
{
    
    BOOL refIdSelected = NO;
    
    for (NSString *item in sentRefIDsToAnimate){
        if ([refId isEqualToString:item]){
            //refid already in sentRefIDsToAnimate
            refIdSelected = YES;
            break;
        }
        else {
            //refid not yet in sentRefIDsToAnimate
            
        }
    }
    
    if (refIdSelected){
        return YES;
    }
    else {
        return NO;
    }
}

-(void) showSentStatusForRefId:(NSString*)refId andIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"showSentStatusForRefId");
    [sentRefIDsToAnimate setObject:indexPath forKey:refId];
    //animate first
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell showSentStatusAnimated:YES];
    
    [self createTemporarySentStatusTimerForRefID:refId];
}


-(BOOL)timeRefIDsToAnimateContainsRefId:(NSString*)refId
{
    
    BOOL refIdSelected = NO;
    
    for (NSString *item in timeRefIDsToAnimate){
        if ([refId isEqualToString:item]){
            //refid already in sentRefIDsToAnimate
            refIdSelected = YES;
            break;
        }
        else {
            //refid not yet in sentRefIDsToAnimate
            
        }
    }
    
    if (refIdSelected){
        return YES;
    }
    else {
        return NO;
    }
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInt
                                        duration:(NSTimeInterval)duration {
    // The updated y value for the origin.
    CGFloat yLocation;
    
    // Set a new frame to update the origin on orientation change. Remember to set
    // adSize first before you update the frame.
    if (UIInterfaceOrientationIsLandscape(toInt)) {
        bannerView_.adSize = kGADAdSizeSmartBannerLandscape;
        yLocation = self.view.frame.size.width -
        CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
    } else {
        bannerView_.adSize = kGADAdSizeSmartBannerPortrait;
        yLocation = self.view.frame.size.height -
        CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height;
    }
    
    CGRect frame = bannerView_.frame;
    frame.origin = CGPointMake(0.0, yLocation);
    bannerView_.frame = frame;
    
    //    if(hasAdLoaded){
    //        self.tableView.frame = CGRectMake(
    //                                          0.0,
    //                                          0.0,
    //                                          bannerView_.frame.size.width,
    //                                          self.view.frame.size.height - bannerView_.frame.size.height);
    //    }
}

#pragma mark - Ads

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    hasAdLoaded = YES;
    bannerView.frame = CGRectMake(0.0,
                                  self.view.frame.size.height - bannerView.frame.size.height,
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);
    
    if(mustShowAd){
        CGFloat viewHeight = (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? MIN(self.view.frame.size.width,self.view.frame.size.height) : MAX(self.view.frame.size.width,self.view.frame.size.height));
        
        CGFloat inputViewFrameY = viewHeight - bannerView.frame.size.height - self.messageInputView.frame.size.height;
        //            if(mustShowAd){
        //                inputViewFrameY = inputViewFrameY - bannerView_.frame.size.height;
        //            }
        
        
        self.messageInputView.frame = CGRectMake(self.messageInputView.frame.origin.x,
                                                 inputViewFrameY,
                                                 self.messageInputView.frame.size.width,
                                                 self.messageInputView.frame.size.height);
        NSLog(@"bannerview size: %f", bannerView.frame.size.height);
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                               0.0f,
                                               viewHeight - self.messageInputView.frame.origin.y,
                                               0.0f);
        
        
        
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
        
    }
    
    
    
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    hasAdLoaded = NO;
    if(mustShowAd){
        CGFloat viewHeight = (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? MIN(self.view.frame.size.width,self.view.frame.size.height) : MAX(self.view.frame.size.width,self.view.frame.size.height));
        
        CGFloat inputViewFrameY = viewHeight - self.messageInputView.frame.size.height;
        //            if(mustShowAd){
        //                inputViewFrameY = inputViewFrameY - bannerView_.frame.size.height;
        //            }
        self.messageInputView.frame = CGRectMake(self.messageInputView.frame.origin.x,
                                                 inputViewFrameY,
                                                 self.messageInputView.frame.size.width,
                                                 self.messageInputView.frame.size.height);
        
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                               0.0f,
                                               viewHeight - self.messageInputView.frame.origin.y,
                                               0.0f);
        
        
        
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
        
    }
}

#pragma mark - MDLoadingViewDelegate

-(void) mdLoadingViewWasTapped:(MDLoadingView *)loadingView {
    if (loadingView.type == MDLoadingViewTypeFooter) {
        [self refreshRowsAtBottom];
    } else {
        [self refreshRowsAtTop];
    }
}


-(void)setIsConnected{
    NSLog(@"setIsConnected");
    
    [super setIsConnected];
    GADRequest *request = [GADRequest request];
    
    
    //masdee: i read that loadRequest uses the UIKit... so it should run on main thread daw, and thus the fix below. so far, it has not crashed again but i can't be super sure
    if(!hasAdLoaded){
        if(![NSThread isMainThread]){
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [self.view addSubview:bannerView_];
                               NSLog(@"setIsConnected WAS NOT on main thread, but is now");
                               [bannerView_ loadRequest:request];
                           });
        }else{
            [self.view addSubview:bannerView_];
            NSLog(@"setIsConnected is on main thread");
            [bannerView_ loadRequest:request];
        }
    }
}

-(UILabel *)headerErrorLabel{
    if(_headerErrorLabel == nil){
        _headerErrorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [_headerErrorLabel setBackgroundColor:[ChikkaColor grayColor]];
        [_headerErrorLabel setTextColor:[UIColor whiteColor]];
        _headerErrorLabel.textAlignment = NSTextAlignmentCenter;
        _headerErrorLabel.font = [ChikkaFont smallFont];
        _headerErrorLabel.numberOfLines = 2;
        [_headerErrorLabel setText:PROMPT_TAP_OR_PULL_TO_RETRY_MESSAGES_OLDER];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerErrorLabelTapped)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [_headerErrorLabel addGestureRecognizer:tapGestureRecognizer];
        _headerErrorLabel.userInteractionEnabled = YES;
    }
    
    
    return _headerErrorLabel;
}

-(UILabel *)footerErrorLabel{
    if(_footerErrorLabel == nil){
        _footerErrorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [_footerErrorLabel setBackgroundColor:[ChikkaColor grayColor]];
        [_footerErrorLabel setTextColor:[UIColor whiteColor]];
        _footerErrorLabel.textAlignment = NSTextAlignmentCenter;
        _footerErrorLabel.numberOfLines = 2;
        _footerErrorLabel.font = [ChikkaFont smallFont];
        [_footerErrorLabel setText:PROMPT_TAP_OR_PULL_TO_RETRY_MESSAGES_NEWER];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerErrorLabelTapped)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [_footerErrorLabel addGestureRecognizer:tapGestureRecognizer];
        _footerErrorLabel.userInteractionEnabled = YES;
    }
    
    
    return _footerErrorLabel;
}
@end
