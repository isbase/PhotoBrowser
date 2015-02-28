//
//  HHFullScreenViewController.m
//  PhotoBrowser
//
//  Created by Today on 15-1-22.
//  Copyright (c) 2015年 Today. All rights reserved.
//

#import "HHFullScreenViewController.h"
#import "MWTapDetectingView.h"
#import "MWZoomingScrollView.h"



#define PADDING                  10


#define DMSafeRelease(__v) ([__v release], __v = nil);
@interface HHFullScreenViewController ()
{
    NSInteger           _photoCount;
    NSUInteger          _currentPageIndex;      //当前页面
    NSUInteger          _previousPageIndex;     //上一个页面
    CGRect              _previousLayoutBounds;  //上一个页面Bounds
    BOOL                _performingLayout;
}

//mian
@property(nonatomic,retain) UIScrollView            *pagingScrollView;
@property(nonatomic,retain) NSMutableArray          *photos;
@property(nonatomic,retain) NSMutableSet            *visiblePages;         //可见的集合
@property(nonatomic,retain) NSMutableSet            *recycledPages;        //循环利用的集合
//layout
- (void)layoutVisiblePages;
- (void)performLayout;

//Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (MWZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (MWZoomingScrollView *)pageDisplayingPhoto:(id<HHPhotoProtocol>)photo;
- (MWZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

//frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
@end

@implementation HHFullScreenViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
    if ((self = [self init])) {
        [self initPhotoObjectArray:photosArray];
    }
    return self;
}

-(void)initPhotoObjectArray:(NSArray *)photoArr
{
    for (NSString *stringUrl in photoArr) {
        [self.photos addObject:[HHPhoto photoWithURL:[NSURL URLWithString:stringUrl]]];
    }
}

- (void)_initialisation {
    
    _photoCount = NSNotFound;
    _previousLayoutBounds = CGRectZero;
    _currentPageIndex = 0;
    _previousPageIndex = NSUIntegerMax;
    _performingLayout  = NO;
    self.visiblePages = [[NSMutableSet alloc] init];
    self.recycledPages = [[NSMutableSet alloc] init];
    self.photos = [[NSMutableArray alloc] init];

    // Listen for MWPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePhotoLoadingDidEndNotification:)
                                                 name:HHPHOTO_LOADING_DID_END_NOTIFICATION
                                            object:nil];
}

-(void)dealloc
{
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HHPHOTO_LOADING_DID_END_NOTIFICATION object:nil];
    DMSafeRelease(_pagingScrollView);
    DMSafeRelease(_visiblePages);
    DMSafeRelease(_recycledPages);
    DMSafeRelease(_photos);
    [super dealloc];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    UIScrollView *pageScroller = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    pageScroller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pageScroller.pagingEnabled = YES;
    pageScroller.delegate = self;
    pageScroller.showsHorizontalScrollIndicator = YES;
    pageScroller.showsVerticalScrollIndicator = YES;
    pageScroller.backgroundColor = [UIColor blackColor];
    pageScroller.contentSize = [self contentSizeForPagingScrollView];
    self.pagingScrollView = pageScroller;
    [self.view addSubview:pageScroller];
    [pageScroller release];
    
    [self reloadData];
    
}

-(void)sigleFingerTouch
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutVisiblePages];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_performingLayout) return;
    // Tile pages
    [self tilePages];
    
    // Calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
    
}
//functions

#pragma mark - imageForPhoto
-(UIImage *)imageForPhoto:(id<HHPhotoProtocol>)photo
{
    if (photo) {
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
        }
    }
    return nil;
}

#pragma mark - Data
- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    
    // Update layout
    if ([self isViewLoaded]) {
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self.view setNeedsLayout];
    }
    
}

-(NSInteger)numberOfPhotos
{
    if (_photoCount == NSNotFound) {
        _photoCount = self.photos.count;
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (id<HHPhotoProtocol>)photoAtIndex:(NSUInteger)index {
    id <HHPhotoProtocol> photo = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] != [NSNull null]) {
            photo = [_photos objectAtIndex:index];
        }
    }
    return photo;
}

#pragma mark -  layout
- (void)layoutVisiblePages{
    _performingLayout = YES;
    NSUInteger indexPriorToLayout = _currentPageIndex;
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    //调整可见viewframe
    for (MWZoomingScrollView *page in _visiblePages) {
        NSUInteger index = page.index;
        page.frame = [self frameForPageAtIndex:index];
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.view.bounds;
        }
        
    }
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    [self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
    // Reset
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
}
- (void)performLayout{
    
    _performingLayout = YES;
    // Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
}

#pragma mark - Paging
- (void)tilePages{
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
    
    NSInteger pageIndex;
    for (MWZoomingScrollView *page in _visiblePages) {
        pageIndex = page.index;
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
        }
    }
    [_visiblePages minusSet:_recycledPages];
    
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            // Add new page
            MWZoomingScrollView *page = [self dequeueRecycledPage];
            if (!page) {
                page = [[MWZoomingScrollView alloc] initWithPhotoBrowser:self];
            }
            [_visiblePages addObject:page];
            [self configurePage:page forIndex:index];
            [_pagingScrollView addSubview:page];
        }
    }
    
}
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index{
    for (MWZoomingScrollView *page in _visiblePages)
        if (page.index == index) return YES;
    return NO;
}

- (MWZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index{
    MWZoomingScrollView *thePage = nil;
    for (MWZoomingScrollView *page in _visiblePages) {
        if (page.index == index) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (MWZoomingScrollView *)pageDisplayingPhoto:(id<HHPhotoProtocol>)photo{
    MWZoomingScrollView *thePage = nil;
    for (MWZoomingScrollView *page in _visiblePages) {
        if (page.photo == photo) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (MWZoomingScrollView *)dequeueRecycledPage{
    MWZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index{
    page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    page.photo = [self photoAtIndex:index];
}

- (void)didStartViewingPageAtIndex:(NSUInteger)index{
    if (![self numberOfPhotos]) return;
    
    id <HHPhotoProtocol> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    // Notify delegate
    if (index != _previousPageIndex) {
        _previousPageIndex = index;
    }
}

- (void)loadAdjacentPhotosIfNecessary:(id<HHPhotoProtocol>)photo {
    MWZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = page.index;
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <HHPhotoProtocol> photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                id <HHPhotoProtocol> photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                }
            }
        }
    }
}

#pragma mark - HHPhoto Loading Notification

- (void)handlePhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <HHPhotoProtocol> photo = [notification object];
    
    MWZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            // Failed to load
            [page displayImageFailure];
        }
    }
}



#pragma mark - frames
- (CGRect)frameForPagingScrollView{
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index{
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize)contentSizeForPagingScrollView{
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index{
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

@end
