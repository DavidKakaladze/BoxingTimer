//
//  ViewController.h
//  BoxingTimer
//
//  Created by David Kakaladze on 07.01.16.
//  Copyright © 2016 David Kakaladze. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UIPickerView) NSArray *pickerView;

@property (weak, nonatomic) IBOutlet UILabel *timeWorkText;
@property (weak, nonatomic) IBOutlet UILabel *timeRestText;
@property (weak, nonatomic) IBOutlet UILabel *roundText;

@property (strong,nonatomic) NSArray * rounds;
@property (strong,nonatomic) NSArray * timeWork;
@property (strong,nonatomic) NSArray * timeRest;

@property (nonatomic) int roundsCount;
@property (nonatomic) int timeWorkCount;
@property (nonatomic) int timeRestCount;
@property (nonatomic) BOOL isWorking;
@property (nonatomic) int countDown;

@end
