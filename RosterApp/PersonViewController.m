//
//  PersonViewController.m
//  RosterApp
//
//  Created by Reed Sweeney on 4/8/14.
//  Copyright (c) 2014 Reed Sweeney. All rights reserved.
//
 
#import "PersonViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Person.h"
#import "DataController.h"
#import "ScrollTopView.h"

@interface PersonViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIActionSheet *myActionSheet;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UIView *primaryView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *githubField;
@property (weak, nonatomic) IBOutlet UITextField *twitterField;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@end

@implementation PersonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.selectedPerson.firstName && self.selectedPerson.lastName) {
        self.fullNameTextField.text = [NSString stringWithFormat:@"%@ %@", self.selectedPerson.firstName, self.selectedPerson.lastName];
    }
    self.githubField.text = self.selectedPerson.github;
    self.twitterField.text = self.selectedPerson.twitter;
    
    if (_selectedPerson.avatar)
    {
        _photoButton.backgroundColor = [UIColor clearColor];
        [self.photoButton setBackgroundImage:self.selectedPerson.avatar forState:UIControlStateNormal] ;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.fullNameTextField.delegate = self;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.primaryView.backgroundColor = self.selectedPerson.personColor;
    _photoButton.imageView.layer.cornerRadius = _photoButton.imageView.frame.size.width/3.0;
    _photoButton.imageView.layer.masksToBounds = YES;
    
    NSMutableArray *sliders = [NSMutableArray new];
    for (id subView in self.primaryView.subviews) {
        if ([subView isKindOfClass:[UISlider class]]) {
            [sliders addObject:subView];
        }
    }
    
    UISlider *sliderR = [sliders objectAtIndex:0];
    UISlider *sliderG = [sliders objectAtIndex:1];
    UISlider *sliderB = [sliders objectAtIndex:2];
    
    CGFloat r,g,b,a;
    [self.selectedPerson.personColor getRed:&r green:&g blue:&b alpha:&a];
    
    [sliderR setValue:r animated:YES];
    [sliderG setValue:g animated:YES];
    [sliderB setValue:b animated:YES];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!_fullNameTextField.text.length) {
        [[[DataController sharedData] studentRoster] removeObject:self.selectedPerson];
    } else {
        self.selectedPerson.firstName = [[_fullNameTextField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] firstObject];
        self.selectedPerson.lastName = [[_fullNameTextField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lastObject];
        self.selectedPerson.github = _githubField.text;
        self.selectedPerson.twitter = _twitterField.text;   
    }
    
    
    [[DataController sharedData] save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (IBAction)CameraButtonPressed:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.myActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        
    }
    else {
        self.myActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Choose Photo", nil];
        
    }
    
    
    [self.myActionSheet showInView:self.view];

    NSLog(@"button pressed");
    
}

#pragma mark - UIActionSheet Delegate Methods


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.allowsEditing = YES;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Photo"])
    {
        //do this later
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Photo"])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    } else {
        
        return;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    _photoButton.backgroundColor = [UIColor clearColor];
    [_photoButton setBackgroundImage:[info objectForKey:UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
    _photoButton.imageView.layer.cornerRadius = _photoButton.imageView.frame.size.width/3.0;
    _photoButton.imageView.layer.masksToBounds = YES;
    self.selectedPerson.avatar = editedImage;
    [[DataController sharedData] save];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Completed");
        
        ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
            [assetsLibrary writeImageToSavedPhotosAlbum:editedImage.CGImage
                                            orientation:ALAssetOrientationUp
                                        completionBlock:^(NSURL *assetURL, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error, Saving Image: %@", error.localizedDescription);
                                            }
                                        }];
        } else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot save photo"
                                                                message:@"Authorization status not granted"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else
        {
            NSLog(@"Authorization Not Determined");
        }
    }];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    for (UIControl *control in self.view.subviews) {
//        if ([control isKindOfClass:[UITextField class]])
//            [control endEditing:YES];
//    }
    [self.primaryView endEditing:YES];
    
}

-(IBAction)sharePhoto:(id)sender
{
    UIActivityViewController *sharePhotoVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.selectedPerson.avatar, [NSURL URLWithString:@"http://www.reedsweeney.com"]] applicationActivities:nil];
    [self presentViewController:sharePhotoVC animated:YES completion:nil];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 200) animated:YES];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

-(IBAction)sliderSlid:(UISlider *)sender
{
    CGFloat r,g,b,a;
    [self.selectedPerson.personColor getRed:&r green:&g blue:&b alpha:&a];
    
    switch (sender.tag) {
        case 1:
            r = sender.value;
            break;
        case 2:
            g = sender.value;
            break;
        case 3:
            b = sender.value;
    }
    
    UIColor *newColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    self.selectedPerson.personColor = newColor;
    self.primaryView.backgroundColor = newColor;
    
}

@end









