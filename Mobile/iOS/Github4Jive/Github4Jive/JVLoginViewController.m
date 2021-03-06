//
//  JVLoginViewController.m
/*
 Copyright 2014 Jive Software
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/* WHAT'S INSIDE:
 * This is a view controller that handles logging into a Jive instance
 * and takes care of displaying errors.
 *
 * Check out -loginToJive.
 *
 * We also use this controller to forward the user to Github for login.
 */

#import "JVLoginViewController.h"
#import "JVJiveFactory.h"
#import <Jive/Jive.h>
#import "JVGithubClient.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import <Masonry.h>
#import "JVLandingViewController.h"


@interface JVLoginViewController ()

@property (nonatomic) JVGithubClient *githubClient;

@property (nonatomic) JVJiveFactory *jiveFactory;
@property (nonatomic) JivePerson *jiveMePerson;

@property (nonatomic) UILabel *loginHeaderLabel;
@property (nonatomic) UITextField *userName;
@property (nonatomic) UITextField *password;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation JVLoginViewController

-(id)initWithJiveFactory:(JVJiveFactory*)jiveFactory {
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.githubClient = [JVGithubClient new];
        self.jiveFactory = jiveFactory;
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    self.title = NSLocalizedString(@"JVLoginViewControllerTitle", nil);

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.loginHeaderLabel = [UILabel new];
    self.loginHeaderLabel.text = NSLocalizedString(@"JVLoginViewControllerLoginHeaderText", nil);
    self.loginHeaderLabel.textAlignment = NSTextAlignmentCenter;
    self.loginHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0f];
    
    self.userName = [UITextField new];
    self.userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.userName.borderStyle = UITextBorderStyleRoundedRect;
    self.userName.delegate = self;
    self.userName.placeholder = NSLocalizedString(@"JVLoginViewControllerUsername", nil);
    
    self.password = [UITextField new];
    self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.password.borderStyle = UITextBorderStyleRoundedRect;
    self.password.secureTextEntry = YES;
    self.password.delegate = self;
    self.password.placeholder = NSLocalizedString(@"JVLoginViewControllerPassword", nil);

    self.activityIndicator = [UIActivityIndicatorView new];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.loginHeaderLabel];
    [self.loginHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(10);
        make.left.equalTo(self.view).with.offset(20);
        make.right.equalTo(self.view).with.offset(-20);
    }];

    [self.view addSubview:self.userName];
    [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginHeaderLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.view).with.offset(20);
        make.right.equalTo(self.view).with.offset(-20);
    }];
    
    [self.view addSubview:self.password];
    [self.password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userName.mas_bottom).with.offset(10);
        make.left.equalTo(self.userName);
        make.right.equalTo(self.userName);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    self.password.text = nil;
    [self.userName becomeFirstResponder];
    [super viewDidAppear:animated];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userName) {
        [self.password becomeFirstResponder];
    } else if (self.userName.text.length == 0) {
        [self.userName becomeFirstResponder];
    } else if (self.password.text.length > 0) {
        [self loginToJive];
    }
    
    return NO;
}

#pragma mark - Private API

- (void)loginToJive {
    [self.activityIndicator startAnimating];
    [self.password resignFirstResponder];
    self.userName.enabled = NO;
    self.password.enabled = NO;
    [self.jiveFactory loginWithName:self.userName.text
                           password:self.password.text
                           complete:^(JivePerson *person) {
                               [self resetLoginView];

                               self.jiveMePerson = person;
                               [self loginSucceededSoAuthToGithub];
                           } error:^(NSError *error) {
                               [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"JVLoginViewControllerJiveLoginError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
                               [self resetLoginView];
                               [self.password becomeFirstResponder];
                           }];

}

- (void)loginSucceededSoAuthToGithub {
    
    GTMOAuth2ViewControllerTouch *oauthViewController = [self.githubClient oauthViewControllerWithSuccess:^{
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [self proceedAfterLogin];
    } onError:^(NSError *error) {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"JVLoginViewControllerGithubError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }];
    [[self navigationController] pushViewController:oauthViewController animated:YES];
    
}

- (void)proceedAfterLogin {
    JVLandingViewController *landingViewController = [[JVLandingViewController alloc] initWithJiveFactory:self.jiveFactory githubClient:self.githubClient jiveMePerson:self.jiveMePerson];
    [self.navigationController setViewControllers:@[landingViewController]];
}

- (void)resetLoginView {
    [self.activityIndicator stopAnimating];
    self.userName.enabled = YES;
    self.password.enabled = YES;
    self.password.text = nil;
}



@end
