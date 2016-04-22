//
//  MoreViewController.h
//  BoxerTimer
//
//  Created by David Kakaladze on 14.01.16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MoreViewController : UIViewController <MFMailComposeViewControllerDelegate>

- (IBAction)contactToDeveloperPressed:(id)sender;
- (IBAction)linkToVKPressed:(id)sender;

@end

@interface CollectionViewClass : UICollectionViewController
{
    NSArray *collectionImages;
}
@end
