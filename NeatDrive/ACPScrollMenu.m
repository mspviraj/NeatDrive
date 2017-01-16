//
//  ACPScrollContainer.m
//  ACPScrollMenu
//
//  Created by Antonio Casero Palmero on 8/4/13.
//  Copyright (c) 2013 ACP. All rights reserved.
//

#import "ACPScrollMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kScrollViewFirstWidth = 12.0f;
static CGFloat const kScrollViewItemMarginWidth = 5.0f;
static CGFloat const kScrollViewItemMarginHeight = 5.0f;

@implementation ACPScrollMenu



# pragma mark -
# pragma mark Initialization
# pragma mark -


- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		// Do something
	}
	return self;
}

- (id)initACPScrollMenuWithFrame:(CGRect)frame withBackgroundColor:(UIColor *)bgColor menuItems:(NSArray *)menuItems {
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}
    
	if (menuItems.count == 0) {
		return nil;
	}
    
	[self setUpACPScrollMenu:menuItems];
	[self setACPBackgroundColor:bgColor];
    
	return self;
}

- (void)setUpACPScrollMenu:(NSArray *)menuItems {
	if (menuItems.count == 0) {
		return;
	}
    
    
    
	NSUInteger menuItemsArrayCount = menuItems.count;
    
    [_scrollView removeFromSuperview];
    
	// Setting ScrollView
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    if(_fixSizeEnable){
        
        CGFloat scrollViewWidth = _scrollView.bounds.size.width;
        CGFloat actualWidth = scrollViewWidth - kScrollViewFirstWidth * 2 - (menuItems.count - 1) * kScrollViewItemMarginWidth;
        CGFloat actualItemWidth = actualWidth / menuItems.count;
        
        for (ACPItem *menuItem in menuItems){
            
            menuItem.frame = CGRectMake(menuItem.frame.origin.x, menuItem.frame.origin.y, actualItemWidth, menuItem.frame.size.height - kScrollViewItemMarginHeight * 2);
        }
    }
    
	ACPItem *menuItem = menuItems[0];
    
	_scrollView.contentSize = CGSizeMake(kScrollViewFirstWidth * 2 + (kScrollViewItemMarginWidth * (menuItemsArrayCount - 1)) + menuItem.frame.size.width * menuItemsArrayCount, self.frame.size.height);
    
	// Do not show scrollIndicator
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
    
	_scrollView.backgroundColor = [UIColor clearColor];
	[_scrollView setUserInteractionEnabled:YES];
	[self addSubview:_scrollView];
    
	self.menuArray = menuItems;
	[self setMenu];
    
    
	_animationType = ACPZoomOut;
    
}

- (void)setMenu {
	
    
    if(_fixSizeEnable){
        
        
        int i = 0;
        for (ACPItem *menuItem in _menuArray) {
            menuItem.tag = 1000 + i;
            
            menuItem.center = CGPointMake(menuItem.frame.size.width / 2 + kScrollViewFirstWidth + kScrollViewItemMarginWidth * i + menuItem.frame.size.width * i, self.frame.size.height / 2);
            menuItem.delegate = self;
            [_scrollView addSubview:menuItem];
            
            i++;
        }
    }
    else {
        
        int i = 0;
        for (ACPItem *menuItem in _menuArray) {
            menuItem.tag = 1000 + i;
            menuItem.center = CGPointMake(menuItem.frame.size.width / 2 + kScrollViewFirstWidth + kScrollViewItemMarginWidth * i + menuItem.frame.size.width * i, self.frame.size.height / 2);
            menuItem.delegate = self;
            [_scrollView addSubview:menuItem];
            
            i++;
        }
    }
}


# pragma mark -
# pragma mark Delegate Methods
# pragma mark -

- (void)itemTouchesBegan:(ACPItem *)item {
	//item.highlighted = YES;
}

- (void)itemTouchesEnd:(ACPItem *)item {
	// blowUp animation
    
	[self startAnimation:item];
    
    if(item.block) {
        item.block(item);
    }
	if ([_delegate respondsToSelector:@selector(scrollMenu:didSelectIndex:)]) {
		[_delegate scrollMenu:(id)self didSelectIndex:item.tag - 1000];
	}
}

# pragma mark -
# pragma mark Animation & behaviour
# pragma mark -

- (void)startAnimation:(ACPItem *)item {
	[self removeHighlighted];
	item.highlighted = YES;
	switch (_animationType) {
		case ACPFadeZoomIn: {
			[UIView animateWithDuration:0.25f animations: ^{
			    CGAffineTransform scaleUpAnimation = CGAffineTransformMakeScale(1.9f, 1.9f);
			    item.transform = scaleUpAnimation;
			    item.alpha = 0.2;
			} completion: ^(BOOL finished) {
			    [UIView animateWithDuration:0.25f animations: ^{
			        item.transform = CGAffineTransformIdentity;
			        item.alpha = 1.0f;
				} completion: ^(BOOL finished) {
			        item.highlighted = YES;
				}];
			}];
			break;
		}
            
		case ACPFadeZoomOut: {
			[UIView animateWithDuration:0.1f animations: ^{
			    CGAffineTransform scaleDownAnimation = CGAffineTransformMakeScale(0.9f, 0.9f);
			    item.transform = scaleDownAnimation;
			    item.alpha = 0.2;
			} completion: ^(BOOL finished) {
			    [UIView animateWithDuration:0.1f animations: ^{
			        item.transform = CGAffineTransformIdentity;
			        item.alpha = 1.0f;
				} completion: ^(BOOL finished) {
			        item.highlighted = YES;
				}];
			}];
			break;
		}
            
		case ACPZoomOut: {
			[UIView animateWithDuration:0.1f animations: ^{
			    CGAffineTransform scaleDownAnimation = CGAffineTransformMakeScale(0.9f, 0.9f);
			    item.transform = scaleDownAnimation;
			} completion: ^(BOOL finished) {
			    [UIView animateWithDuration:0.1f animations: ^{
			        item.transform = CGAffineTransformIdentity;
				} completion: ^(BOOL finished) {
			        item.highlighted = YES;
				}];
			}];
			break;
		}
            
		default: {
			[UIView animateWithDuration:0.25f animations: ^{
			    CGAffineTransform scaleUpAnimation = CGAffineTransformMakeScale(1.9f, 1.9f);
			    item.transform = scaleUpAnimation;
			    item.alpha = 0.2;
			} completion: ^(BOOL finished) {
			    [UIView animateWithDuration:0.25f animations: ^{
			        item.transform = CGAffineTransformIdentity;
			        item.alpha = 1.0f;
				} completion: ^(BOOL finished) {
			        item.highlighted = YES;
				}];
			}];
			break;
		}
	}
}

- (void)removeHighlighted  {
	for (ACPItem *menuItem in self.menuArray) {
		menuItem.highlighted = NO;
	}
}

- (void)setThisItemHighlighted:(NSInteger)itemNumber {
	[self removeHighlighted];
	[[self.menuArray objectAtIndex:itemNumber] setHighlighted:YES];
}

# pragma mark -
# pragma mark Extra configuration
# pragma mark -


- (void)setACPBackgroundColor:(UIColor *)color {
	self.backgroundColor = color;
}

- (NSArray *)menuItems{
    
    return _menuArray;
}

@end
