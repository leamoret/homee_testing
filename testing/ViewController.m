//
//  ViewController.m
//  testing
//
//  Created by Léa Moret on 1/25/16.
//  Copyright © 2016 Léa Moret. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic) UIImage* myImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc]init];
    button.frame = CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 30);
    [button addTarget:self action:@selector(loadPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    button.layer.zPosition = 10;
    [self.view addSubview:button];
}

-(void)loadPhotoLibrary{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"8");
}

- (UIImage*)compressImage:(UIImage*)image {
    float imageHeight = image.size.height;
    float imageWidth = image.size.width;
    float imageRatio = imageWidth/imageHeight;
    
    //maxHeight and maxWidth could be changed
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float maxRatio = maxWidth/maxHeight;
    
    //compressionFactor can be changed
    float compressionFactor = 0.6;
    
    if(imageHeight > maxHeight || imageWidth > maxWidth) {
        if(imageRatio > maxRatio) {
            imageRatio = maxHeight/imageHeight;
            imageWidth = imageRatio * imageWidth;
            imageHeight = maxHeight;
        }
        else if(imageRatio < maxRatio) {
            imageRatio = maxWidth/imageWidth;
            imageHeight = imageRatio * imageHeight;
            imageWidth = maxWidth;
        }
        else {
            imageHeight = maxHeight;
            imageWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, imageWidth, imageHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionFactor);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage * pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //compress image
    self.myImage = [self compressImage:pickedImage];
    
    //display image
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.userInteractionEnabled = YES;
    
    //display image
    imageview.image = self.myImage;
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.frame= self.view.frame;
    [self.view addSubview:imageview];
    
    //add button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(imageview.bounds.size.width/10, imageview.bounds.size.height/10, 60.0, 30.0);
    
    //set color of button
    //CGPoint point = CGPointMake(60, 45);
    if([self backButtonColor:imageview.image]) {
        button.backgroundColor = [UIColor whiteColor];
    }
    else {
        button.backgroundColor = [UIColor blackColor];
    }
    [imageview addSubview:button];

    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

-(BOOL) backButtonColor:(UIImage*)image {
    
    CGImageRef imageRef = [image CGImage];
    
    //get width and height of the image
    NSInteger width = CGImageGetWidth(imageRef);
    NSInteger height = CGImageGetHeight(imageRef);
    
    //get width and height of the point
    NSInteger pointX = width/10;
    NSInteger pointY = height/10;
    
    //create a bitmap context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, -pointY);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), imageRef);
    CGContextRelease(context);
    
    //get RGB values
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    
    //get the luminosity
    CGFloat lum = red*0.2126 + green*0.7152 + blue*0.0722;
    
    //CGFloat a = red*0.299 + green*0.587 + blue*0.114;
    
    //return true for white and false for black
    if(lum > 0.179) {return false;}
    else {return true;}
    
//    if(a>186) {
//        return false;
//    }
//    else {
//        return true;
//    }
}

@end
