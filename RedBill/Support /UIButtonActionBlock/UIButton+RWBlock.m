//
//  UIButton+RWBlock.m
//  CP
//
//  Created by AppstoneLab.
//  Copyright (c) 2017 AppstoneLab. All rights reserved.
//

#import "UIButton+RWBlock.h"
#import <objc/runtime.h>

@implementation UIButton (RWBlock)

#pragma mark - Custom accessors

- (void)addActionblock:(RWButtonActionBlock)actionBlock forControlEvents:(UIControlEvents)events {
  
  // Store it.
  objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  
  // Add self as target and -performActionBlock as action.
  [self addTarget:self action:@selector(performActionBlock:) forControlEvents:events];
}

- (RWButtonActionBlock)actionBlock {
  return objc_getAssociatedObject(self, @selector(actionBlock));
}

#pragma mark - IBActions

- (IBAction)performActionBlock:(id)sender {
  
  if (self.actionBlock) {
    self.actionBlock(sender);
  }
}

@end
