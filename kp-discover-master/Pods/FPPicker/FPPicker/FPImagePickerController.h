//
//  FPImagePickerController.h
//  FPPicker
//
//  Created by Ruben on 9/18/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPSource.h"

@interface FPImagePickerController : UIImagePickerController

@property (nonatomic, strong) FPSource *fpSourcetype;

@end
