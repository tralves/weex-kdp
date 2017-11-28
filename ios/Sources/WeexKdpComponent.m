//
//  WeexKdpComponent.m
//  Pods-WeexDemo
//
//  Created by Tiago Alves on 20/11/17.
//

#import <Foundation/Foundation.h>
#import "WeexKdpComponent.h"
#import <PlayKit/PlayKit-Swift.h>
#import <WeexPluginLoader/WeexPluginLoader.h>

@interface WeexKdpComponent()<PlayerDelegate>

@property(nonatomic, assign) CGRect frame;
@property (nonatomic, strong) id<Player> player;
@property (strong, nonatomic) PlayerView *playerContainer;


@end

@implementation WeexKdpComponent

WX_PlUGIN_EXPORT_COMPONENT(weexKdp,WeexKdpComponent)

/**
 *  @abstract Initializes a new component using the specified  properties.
 *
 *  @param ref          the identity string of component
 *  @param type         component type
 *  @param styles       component's styles
 *  @param attributes   component's attributes
 *  @param events       component's events
 *  @param weexInstance the weexInstance with which the component associated
 *
 *  @return A WXComponent instance.
 */
- (instancetype)initWithRef:(NSString *)ref
type:(NSString*)type
styles:(nullable NSDictionary *)styles
attributes:(nullable NSDictionary *)attributes
events:(nullable NSArray *)events
weexInstance:(WXSDKInstance *)weexInstance{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    
    PlayKitManager.logLevel = PKLogLevelInfo;
    
    if (self )
    {
        CGPoint origin = [[UIScreen mainScreen] bounds].origin;
        CGSize size = [[UIScreen mainScreen] bounds].size;
        
        if (styles[@"left"])
        {
            origin.x = [styles[@"left"] floatValue];
        }
        
        if (styles[@"top"])
        {
            origin.y = [styles[@"top"] floatValue];
        }
        
        if (styles[@"width"])
        {
            size.width = [styles[@"width"] floatValue];
        }
        
        if (styles[@"height"])
        {
            size.height = [styles[@"height"] floatValue];
        }
        
        self.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        
        self.componentFrame = self.frame;
        
        
        
        
    }
    
    return self;
}

- (BOOL)isViewLoaded
{
    return (self.kdpview != nil);
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    NSError *error = nil;
    self.player = [[PlayKitManager sharedInstance] loadPlayerWithPluginConfig:nil error:&error];
    // make sure player loaded
    if (!error) {
        // 2. Register events if have ones.
        // Event registeration must be after loading the player successfully to make sure events are added,
        // and before prepare to make sure no events are missed (when calling prepare player starts buffering and sending events)
        
        // 3. Prepare the player (can be called at a later stage, preparing starts buffering the video)
        [self preparePlayer];
    } else {
        // error loading the player
    }
    [self.player play];
}

- (UIView *)loadView
{
    if(!self.kdpview){
        UIView *kdpview = [[UIView alloc] initWithFrame:self.frame];
        kdpview.bounds = self.frame;

        self.playerContainer = [[PlayerView alloc] initWithFrame:self.frame];
        [kdpview addSubview:self.playerContainer];
        
//        UIImageView *imgview2 = [[UIImageView alloc] initWithFrame:kdpview.bounds];
//        [imgview2 setImage:[UIImage imageNamed:@"AppIcon"]];
//        [imgview2 setClipsToBounds:YES];
//        [kdpview addSubview:imgview2];

        self.kdpview = kdpview;
    }
    return self.kdpview;
}

- (void)preparePlayer {
    self.player.view = self.playerContainer;
    NSURL *contentURL = [[NSURL alloc] initWithString:@"https://cdnapisec.kaltura.com/p/2215841/playManifest/entryId/1_w9zx2eti/format/applehttp/protocol/https/a.m3u8"];
    
    // create media source and initialize a media entry with that source
    NSString *entryId = @"sintel";
    PKMediaSource* source = [[PKMediaSource alloc] init:entryId contentUrl:contentURL mimeType:nil drmData:nil mediaFormat:MediaFormatHls];
    NSArray<PKMediaSource*>* sources = [[NSArray alloc] initWithObjects:source, nil];
    // setup media entry
    PKMediaEntry *mediaEntry = [[PKMediaEntry alloc] init:entryId sources:sources duration:-1];
    
    // create media config
    MediaConfig *mediaConfig = [[MediaConfig alloc] initWithMediaEntry:mediaEntry startTime:0.0];
    
    // prepare the player
    [self.player prepare:mediaConfig];
}

- (IBAction)playTapped:(id)sender {
    if(!self.player.isPlaying) {
        [self.player play];
    }
}

- (IBAction)pauseTapped:(id)sender {
    if(self.player.isPlaying) {
        [self.player pause];
    }
}


@end