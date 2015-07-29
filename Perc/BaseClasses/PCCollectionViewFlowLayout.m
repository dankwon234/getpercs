//
//  PCCollectionViewFlowLayout.m
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCCollectionViewFlowLayout.h"
#import "Config.h"

@interface PCCollectionViewFlowLayout ()
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@end

@implementation PCCollectionViewFlowLayout
@synthesize isHorizontal;

- (id)init
{
    self = [super init];
    if (self){
        self.isHorizontal = YES;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 6.0f;
        self.itemSize = CGSizeMake([PCCollectionViewFlowLayout cellWidth], [PCCollectionViewFlowLayout cellHeight]);
        
        [self setup];
    }
    
    
    return self;
}

- (id)initVerticalFlowLayout
{
    self = [super init];
    if (self){
        self.isHorizontal = NO;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumInteritemSpacing = 10; // horizontal gap between columns
        self.minimumLineSpacing = 12.0f; // vertical gap between rows
        self.itemSize = CGSizeMake([PCCollectionViewFlowLayout verticalCellWidth], [PCCollectionViewFlowLayout cellHeight]);
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.itemSize = CGSizeMake([PCCollectionViewFlowLayout verticalCellWidth], [PCCollectionViewFlowLayout cellHeight]);
    self.sectionInset = UIEdgeInsetsMake(0.0f, kCellPadding, 0.0f, kCellPadding);
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
}


+ (CGFloat)cellPadding
{
    return kCellPadding;
}

+ (CGFloat)verticalCellWidth
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    return (frame.size.width > 320.0f) ? 165.0f : 137.0f;
}

+ (CGFloat)cellWidth
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    return (frame.size.width > 320.0f) ? 140.0f : 123.0f;
}

+ (CGFloat)cellHeight
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGFloat h = (frame.size.width > 320.0f) ? 240.0f : 216.0f;
    return h;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    
    if (self.dynamicAnimator.behaviors.count > 0)
        return;
    
    CGSize contentSize = self.collectionView.contentSize;
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height)];
    [items enumerateObjectsUsingBlock:^(id<UIDynamicItem> obj, NSUInteger idx, BOOL *stop) {
        UIAttachmentBehavior *behaviour = [[UIAttachmentBehavior alloc] initWithItem:obj
                                                                    attachedToAnchor:[obj center]];
        
        behaviour.length = 0.0f;
        behaviour.damping = 0.9f;
        behaviour.frequency = 1.0f;
        
        [self.dynamicAnimator addBehavior:behaviour];
    }];
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
//    NSLog(@"shouldInvalidateLayoutForBoundsChange:");
    UIScrollView *scrollView = self.collectionView;
    
    if (self.isHorizontal){
        CGFloat delta = newBounds.origin.x - scrollView.bounds.origin.x;
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
            CGFloat yDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
            CGFloat xDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
            CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1300.0f;
            
            UICollectionViewLayoutAttributes *item = springBehaviour.items.firstObject;
            CGPoint center = item.center;
            center.x += (delta < 0) ? MAX(delta, delta*scrollResistance) : MIN(delta, delta*scrollResistance);
            item.center = center;
            
            [self.dynamicAnimator updateItemUsingCurrentState:item];
        }];
        
        return NO;
    }
    
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1300.0f;
        
        UICollectionViewLayoutAttributes *item = springBehaviour.items.firstObject;
        CGPoint center = item.center;
        center.y += (delta < 0) ? MAX(delta, delta*scrollResistance) : MIN(delta, delta*scrollResistance);
        item.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}


@end
