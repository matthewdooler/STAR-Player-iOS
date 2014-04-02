//
//  ViewController.m
//  STAR Player
//
//  Created by Matthew Dooler on 06/11/2012.
//  Copyright (c) 2012 Matthew Dooler. All rights reserved.
//

#import "ViewController.h"
#import "AudioStreamer.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@interface ViewController ()

@end

@implementation ViewController



AudioStreamer *streamer;
BOOL playing;
NSTimer *myTimer;



NSString *show_name;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"View loaded");
    
    self.playButtonImage = [UIImage imageNamed:@"play-button.png"];
    self.pauseButtonImage = [UIImage imageNamed:@"pause-button.png"];
    
    [self showInfoUpdater];
    
    NSLog(@"View extras loaded");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getShowNameFromWeb:(NSString**)str {
    
    NSURL *url = [ NSURL URLWithString: @"http://www.standrewsradio.com/current-show-info.php?name"];
    NSURLRequest *req = [ NSURLRequest requestWithURL: url
                                          cachePolicy: NSURLRequestReloadIgnoringCacheData
                                      timeoutInterval: 30.0 ];
    NSError *err;
    NSURLResponse *res;
    NSData *d = [ NSURLConnection sendSynchronousRequest: req
                                       returningResponse: &res
                                                   error: &err ];
    
    
    NSString *t = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    *str = [t copy];
}

//int lastUpdated_hour;
//int lastUpdated_minute;
//NSDate *current_date = NULL;
//NSDate *last_info_check = NULL;
NSTimeInterval last_info_check = 0;

- (void)updateShowImage {
    
    NSURL *imageURL = [NSURL URLWithString:@"http://www.standrewsradio.com/current-show-info.php?image"];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    //[self.show_image setImage:image];
    self.show_image.image = image;
}

- (void)updateShowInfo {
    
    NSDate *current_date = [NSDate date];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: current_date];
    
    //int hour = [dateComps hour];
    int minute = [dateComps minute];
    
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if(last_info_check == 0) {
        
        /* First check */
        
        // Get show name
        NSString *new_show_name = [[NSString alloc] init];
        [self getShowNameFromWeb:&new_show_name];
        show_name = [new_show_name copy];
        [new_show_name release];
        [self.show_label setText:show_name];
        
        // Get and show image from webserver
        [self updateShowImage];
        
        last_info_check = currentTimestamp;
        
    } else {
        
        // Number of seconds since we last checked
        NSTimeInterval timeSinceLastCheck =  currentTimestamp - last_info_check;
        
        // Only ask webserver for name when we're on the hour and haven't already checked in the last minute
        if(minute == 0 && timeSinceLastCheck > 60) {
            
            // Keep asking webserver for name every minute for the next 10m until it gives us a different name
            // This allows for clock inaccuracy but also makes sure not to spam the server for shows longer than 1h
            int timesChecked = 0;
            while(true) {
                
                if(timesChecked >= 10) {
                    break;
                }
                
                NSString *new_show_name = [[NSString alloc] init];
                [self getShowNameFromWeb:&new_show_name];
                
                if([new_show_name isEqualToString:show_name]) {
                    NSLog(@"Show didn't change, checking again in 60s");
                    [new_show_name release];
                    sleep(60);
                } else {
                    
                    // Show name changed, so show it in the display
                    show_name = [new_show_name copy];
                    [new_show_name release];
                    [self.show_label setText:show_name];
                    NSLog(@"Show changed to %@", show_name);
                    
                    // Image will have changed, so get it from the webserver and show it
                    [self updateShowImage];
                    
                    break;
                }
                
                timesChecked++;
            }
            
            last_info_check = currentTimestamp;
        }
    }
    
}

- (void)showInfoUpdater {
    
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1// TODO: can realisticly be 60s
                                               target:self
                                             selector:@selector(updateShowInfo)
                                             userInfo:nil
                                              repeats:YES];
    //});
    
    
}
- (IBAction)pressedPlaybackButton:(id)sender event:(UIEvent*)event {
    
    if(playing) {
        // Stop
        NSLog(@"Stopping playback");
        [streamer stop];
        playing = false;
        [sender setBackgroundImage:self.playButtonImage forState:UIControlStateNormal];
        NSLog(@"Stopped");
    } else {
        NSLog(@"Starting playback");
        
        NSString *escapedValue = @"http://stream.standrewsradio.com:8080/stream/1/";
        NSURL *url = [NSURL URLWithString:escapedValue];
        streamer = [[AudioStreamer alloc] initWithURL:url];
        [streamer start];
        
        playing = true;
        [sender setBackgroundImage:self.pauseButtonImage forState:UIControlStateNormal];
        NSLog(@"Playing");
    }
}

- (void)dealloc {
    [_show_image release];
    //[_playback_button release];
    [_show_label release];
    [super dealloc];
}
@end
