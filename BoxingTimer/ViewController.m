//
//  ViewController.m
//  BoxingTimer
//
//  Created by David Kakaladze on 07.01.16.
//  Copyright © 2016 David Kakaladze. All rights reserved.
//

//исправить:
//1) При работе таймера можно изменить время и раунды, нужно чтобы нельзя
//2) При нажатии на Cancel в запущеном таймере он не останавливается, должно все обнуляться и останавливаться
//3) При нажатии на Stop, а потом на Start все начинается сначала, нужно чтобв продолжало с остановленного места
//4) При повторном нажатии старт\стоп не нужно показывать алерт
//5) когда все раунды заканчиваются нужно счетчики нужно автоматически обнулять
//6) когда заканчивается последний раунд показывает -1, нужно 0
//
//доработать:
//1) UICollectionViewCell смена обоев на таймере
//2) При запущенном таймере вместо UIPickerView меняется на PlayerViewController с подкрузкой музыки с телефона
//3) Сделать набор обоев
//4) поставить нормальные иконки на таббар
//5) Сделать нормальный экран загрузки
//
//в идеале:
//1) разбить все по классам


#import "ViewController.h"
#import "MSWeakTimer.h"
#import <AudioToolbox/AudioServices.h>
#import "MoreViewController.h"



@interface ViewController () <UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) MSWeakTimer *timer;
@property (strong, nonatomic) MSWeakTimer *backgroundTimer;

@property (strong, nonatomic) dispatch_queue_t privateQueue;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
  

    
    //sleep(3);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"boxing.png"]];
    
    self.roundsCount = 1;
    
    //rounds
    NSMutableArray *mutableArrayRounds = [[NSMutableArray alloc] init];
    
    for (int rounds = 1; rounds < 31; rounds++) {
        
        [mutableArrayRounds addObject:[NSString stringWithFormat:@"%d",rounds]];
    }
    self.rounds = [NSArray arrayWithArray:mutableArrayRounds];
    
    //TimeRest
    
    NSMutableArray *mutableArrayTimeRest = [[NSMutableArray alloc] init];
    
    for (int min = 0; min < 6; min++)
        for (int sec = 0; sec < 60; sec+=5)
        {
            
            [mutableArrayTimeRest addObject:[NSString stringWithFormat:@"%d : %d",min, sec]];
        }
    self.timeRest = [NSArray arrayWithArray:mutableArrayTimeRest];
    
    
    //TimeWork
    
    NSMutableArray *mutableArrayTimeWork = [[NSMutableArray alloc] init];
    
    for (int min = 0; min < 6; min++)
        for (int sec = 0; sec < 60; sec+=5)
        {
            
            [mutableArrayTimeWork addObject:[NSString stringWithFormat:@"%d : %d", min, sec]];
        }
    self.timeWork = [NSArray arrayWithArray:mutableArrayTimeWork];
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger title = 0;
    
    if (pickerView.tag == 1) {
        title = [self.rounds count];
    }
    if (pickerView.tag == 2) {
        title =[self.timeRest count];
    }
    if (pickerView.tag == 3) {
        title =[self.timeWork count];
        
    }
    
    return title;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString * titleRow;
    
    if (pickerView.tag == 1) {
        titleRow = [self.rounds objectAtIndex:row];
    }
    if (pickerView.tag == 2) {
        titleRow = [self.timeRest objectAtIndex:row];
    }
    if (pickerView.tag == 3) {
        titleRow = [self.timeWork objectAtIndex:row];
    }
    
    return titleRow;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        self.roundsCount = [[self.rounds objectAtIndex:row] integerValue];
    }
    if (pickerView.tag == 2) {
        self.timeWorkCount = [self convertTime:[self.timeRest objectAtIndex:row]];
    }
    if (pickerView.tag == 3) {
        self.timeRestCount = [self convertTime:[self.timeWork objectAtIndex:row]];
    }
    
}


#pragma mark actions


- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.timer invalidate];
    
    self.roundsCount = 0;
    self.timeWorkCount = 0;
    self.timeRestCount = 0;
    
    self.roundText.text = @"0";
    self.timeWorkText.text = @"0";
    self.timeRestText.text = @"0";
}

- (IBAction)goButtonPressed:(id)sender {
    
    if (_timeWorkCount == 0) {
        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Ошибка!"
                                                         message:@"Задайте время работы"
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil];
        [message show];
        
        NSLog(@"value time work is 0");
        
    } else if (_timeRestCount == 0 ) {
            UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Ошибка!"
                                                             message:@"Задайте время отдыха"
                                                            delegate:nil
                                                   cancelButtonTitle:@"ok"
                                                   otherButtonTitles:nil];
            [message show];
            
            NSLog(@"value time rest is 0");
            
    } else {
        
        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Внимание!"
                                                         message:@"Если выйдите из приложения или заблокируете устройство, таймер собьется!"
                                                        delegate:nil
                                               cancelButtonTitle:@"Я понял"
                                               otherButtonTitles:nil];
        [message show];
        
        #pragma mark Sound
        
        SystemSoundID clickSound;
        AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("gong"), CFSTR("mp3"), NULL), &clickSound);
        AudioServicesPlaySystemSound(clickSound);  //звук
        
        
        {
            static NSString *kStopTimerText = @"Stop";
            static NSString *kStartTimerText = @"Start";
            
            NSString *currentTitle = [sender titleForState:UIControlStateNormal];
            
            if ([currentTitle isEqualToString:kStopTimerText])
            {
                [sender setTitle:kStartTimerText forState:UIControlStateNormal];
                [self.timer invalidate];
            }
            else
            {
                self.roundText.text = [NSString stringWithFormat:@"%i", self.roundsCount];
                self.isWorking = YES;
                self.countDown = self.timeWorkCount;
                
                [sender setTitle:kStopTimerText forState:UIControlStateNormal];
                self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1
                                                                  target:self
                                                                selector:@selector(mainThreadTimerDidFire:)
                                                                userInfo:nil
                                                                 repeats:YES
                                                           dispatchQueue:dispatch_get_main_queue()];
            }
        }
    }
}

#pragma mark convert time

- (int)convertTime:(NSString*)time
{
    NSLog(@"time %@", time);
    long minutes = [[time substringToIndex:1] integerValue];
    long seconds = [[time substringFromIndex:3] integerValue];
    
    return minutes * 60 + seconds;
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark - mainThreadTimer

- (void)mainThreadTimerDidFire:(MSWeakTimer *)timer
{
    self.countDown--;
    
    if(self.isWorking) {
        NSString *formatedText = [self timeFormatted:self.countDown];
        self.timeWorkText.text = formatedText;
    } else {
        NSString *formatedText = [self timeFormatted:self.countDown];
        self.timeRestText.text = formatedText;
    }
    
    if(self.countDown <= 0) {
        if(self.isWorking) {
            self.isWorking = NO;
            self.countDown = self.timeRestCount;
            
            self.roundsCount--;
            self.roundText.text = [NSString stringWithFormat:@"%i", self.roundsCount];
            
            SystemSoundID clickSound;
            AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("gong"), CFSTR("mp3"), NULL), &clickSound);
            AudioServicesPlaySystemSound(clickSound);
            
            if(self.roundsCount <= 0) {
                [self.timer invalidate];
                return;
            }
            
        } else {
            
            self.isWorking = YES;
            self.countDown = self.timeWorkCount;
            
            SystemSoundID clickSound;
            AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("gong"), CFSTR("mp3"), NULL), &clickSound);
            AudioServicesPlaySystemSound(clickSound);
        }
    }
}



#pragma mark backgroundTimer

@end