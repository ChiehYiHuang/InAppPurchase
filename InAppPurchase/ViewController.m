//
//  ViewController.m
//  InAppPurchase
//
//  Created by ChiehYi Huang on 2014/12/10.
//  Copyright (c) 2014年 ChiehYi Huang. All rights reserved.
//
#import "ViewController.h"

#import "CYHPurchase.h"

#define PRODUCT_ID @"vip_level_2"

@interface ViewController () <CYHPurchaseDelegate> {
    NSString *titleText;
    CGFloat scale;
    
    CYHPurchase *cyhPurchase;
    
    UIButton *onButtonGoBack;
    UIButton *onButtonBuy;
    UIButton *onButtonRestore;
    
    UILabel *productTitle;
    UITextView *productDescription;
    
    BOOL isPurchased;
}

@end

@implementation ViewController

#pragma mark - Initialize
- (id)initWithTitleStr:(NSString *)aTitleStr {
    if (self = [super init]) {
        titleText = aTitleStr;
    }
    return self;
}

#pragma mark - Override
- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    onButtonBuy = nil;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Only enable after populated with IAP price.
    onButtonBuy.enabled = NO;
    
    // Request In-App Purchase product info and availability.
    if (![cyhPurchase requestProduct:PRODUCT_ID]) {
        
        // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
        [onButtonBuy setTitle:@"Purchase Disabled in Settings"
                     forState:UIControlStateNormal];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    // Create an instance of CYHPurchase.
    cyhPurchase = [[CYHPurchase alloc] init];
    cyhPurchase.delegate = self;
    
    isPurchased = NO; // default.
    
    CGRect rect;
    UIButton *button;
    UILabel *label;
    UITextView *textView;
    
    rect = CGRectMake(10,
                      100,
                      self.view.frame.size.width - 20,
                      100);
    button = [[UIButton alloc] initWithFrame:rect];
    [button setTitle:@"GO BACK" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = [[UIColor grayColor] CGColor];
    button.layer.borderWidth = 2;
    button.layer.cornerRadius = 20;
    [button addTarget:self action:@selector(onButtonGoBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    onButtonGoBack = button;
    button = nil;
    
    rect = CGRectMake(10,
                      onButtonGoBack.frame.origin.y + onButtonGoBack.frame.size.height,
                      self.view.frame.size.width,
                      100);
    label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    productTitle = label;
    label = nil;
    
    rect = CGRectMake(10,
                      productTitle.frame.origin.y + productTitle.frame.size.height,
                      self.view.frame.size.width - 20,
                      200);
    textView = [[UITextView alloc] initWithFrame:rect];
    textView.backgroundColor = [UIColor clearColor];
    textView.userInteractionEnabled = NO;
    textView.textColor = [UIColor whiteColor];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:textView];
    productDescription = textView;
    textView = nil;
    
    rect = CGRectMake(10,
                      productDescription.frame.origin.y + productDescription.frame.size.height,
                      self.view.frame.size.width - 20,
                      100);
    button = [[UIButton alloc] initWithFrame:rect];
    [button setTitle:@"BUY" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = [[UIColor grayColor] CGColor];
    button.layer.borderWidth = 2;
    button.layer.cornerRadius = 20;
    [button addTarget:self action:@selector(onButtonBuyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    onButtonBuy = button;
    button = nil;
    
    rect = CGRectMake(10,
                      onButtonBuy.frame.origin.y + onButtonBuy.frame.size.height + 10,
                      self.view.frame.size.width - 20,
                      100);
    button = [[UIButton alloc] initWithFrame:rect];
    [button setTitle:@"RESTORE" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = [[UIColor grayColor] CGColor];
    button.layer.borderWidth = 2;
    button.layer.cornerRadius = 20;
    [button addTarget:self action:@selector(onButtonRestoreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    onButtonRestore = button;
    button = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Events Functions
- (void)onButtonGoBackClick:(id)aSender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onButtonBuyClick:(id)aSender {
    if (cyhPurchase.validProduct != nil) {
        // Then, call the purchase method.
        if (![cyhPurchase purchaseProduct:cyhPurchase.validProduct]) {
            // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
            [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"在您花費這筆項目前，請先在iOS設定裡選擇\"允許在此app內購買\"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}
- (void)onButtonRestoreClick:(id)aSender {
    // Restore a customer's previous non-consumable or subscription In-App Purchase.
    // Required if a user reinstalled app on same device or another device.
    
    // Call restore method.
    if (![cyhPurchase restorePurchase]) {
        // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
        [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"在您修復前一筆項目前，請先在iOS設定裡選擇\"允許在此app內購買\"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - CYHPurchaseDelegate Methods
- (void)requestedProduct:(CYHPurchase *)aCYHP identifier:(NSString *)aProductId name:(NSString *)aProductName price:(NSString *)aProductPrice description:(NSString *)aProductDescription {
    NSLog(@"PurchaseViewController RequestedProduct");
    
    if (aProductPrice != nil) {
        // Product is available, so update button title with price.
        productTitle.text = aProductName;
        productDescription.text = aProductDescription;
        [onButtonBuy setTitle:[@"Buy It For " stringByAppendingString:aProductPrice]
                     forState:UIControlStateNormal];
        onButtonBuy.enabled = YES; // Enable buy button.
    } else {
        // Product is NOT available in the App Store, so notify user.
        onButtonBuy.enabled = NO; // Ensure buy button stays disabled.
        [onButtonBuy setTitle:@"TEST_IAP Pack" forState:UIControlStateNormal];
        
        [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"現在無法從App Store中得到相關資訊，請稍候再試。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
- (void)successfulPurchase:(CYHPurchase *)aCYHP identifier:(NSString *)aProductId receipt:(NSData *)aTransactionReceipt {
    NSLog(@"PurchaseViewController successfulPurchase");
    
    // Purchase or Restore request was successful, so...
    // 1 - Unlock the purchased content for your new customer!
    // 2 - Notify the user that the transaction was successful.
    if (!isPurchased) {
        // If paid status has not yet changed, then do so now. Checking
        // isPurchased boolean ensures user is only shown Thank You message
        // once even if multiple transaction receipts are successfully
        // processed (such as past subscription renewals).
        
        isPurchased = YES;
        
        //-------------------------------------
        // 1 - Unlock the purchased content and update the app's stored settings.
        //-------------------------------------
        
        // 2 - Notify the user that the transaction was successful.
        
        [[[UIAlertView alloc] initWithTitle:@"感謝您" message:@"您已成功購買此項目。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
    }
}
- (void)failedPurchase:(CYHPurchase *)aCYHP error:(NSInteger)aErrorCode message:(NSString *)aErrorMessage {
    NSLog(@"PurchaseViewController failedPurchase");
    
    // Purchase or Restore request failed or was cancelled, so notify the user.
    [[[UIAlertView alloc] initWithTitle:@"購買停止" message:@"您取消了交易，或是Apple Store回傳交易錯誤，請稍候再試或是聯絡客服中心。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)incompleteRestore:(CYHPurchase *)aCYHP {
    NSLog(@"PurchaseViewController incompleteRestore");
    
    // Restore queue did not include any transactions, so either the user has not yet made a purchase
    // or the user's prior purchase is unavailable, so notify user to make a purchase within the app.
    // If the user previously purchased the item, they will NOT be re-charged again, but it should
    // restore their purchase.
    
    [[[UIAlertView alloc] initWithTitle:@"修復問題" message:@"無待修復之項目，如要購買的項目，請再點擊購買的按鈕。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)failedRestore:(CYHPurchase *)aCYHP error:(NSInteger)aErrorCode message:(NSString *)aErrorMessage {
    NSLog(@"ViewController failedRestore");
    
    // Restore request failed or was cancelled, so notify the user.
    [[[UIAlertView alloc] initWithTitle:@"修復停止" message:@"您取消了交易，或是前一筆交易無法修復，請稍候再試或是聯絡客服中心。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
