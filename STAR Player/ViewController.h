//
//  ViewController.h
//  STAR Player
//
//  Created by Matthew Dooler on 06/11/2012.
//  Copyright (c) 2012 Matthew Dooler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *show_image;
@property (retain, nonatomic) IBOutlet UILabel *show_label;

@property(nonatomic,retain) UIImage *playButtonImage;
@property(nonatomic,retain) UIImage *pauseButtonImage;
@property (retain, nonatomic) IBOutlet UIWebView *webview;

@end
