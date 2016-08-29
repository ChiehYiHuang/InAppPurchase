//
//  CYHPurchase.h
//  touchableearth
//
//  Created by ChiehYi Huang on 2015/5/18.
//  Copyright (c) 2015年 ChiehYi Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol CYHPurchaseDelegate;

@interface CYHPurchase : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (assign) id <CYHPurchaseDelegate> delegate;
@property (nonatomic, retain) SKProduct *validProduct;

- (BOOL)requestProduct:(NSString *)productId;
- (BOOL)purchaseProduct:(SKProduct *)requestedProduct;
- (BOOL)restorePurchase;

@end

@protocol CYHPurchaseDelegate <NSObject>
@optional

- (void)requestedProduct:(CYHPurchase *)aCYHP identifier:(NSString *)aProductId name:(NSString *)aProductName price:(NSString *)aProductPrice description:(NSString *)aProductDescription;

- (void)successfulPurchase:(CYHPurchase *)aCYHP identifier:(NSString*)aProductId receipt:(NSData*)aTransactionReceipt;
- (void)failedPurchase:(CYHPurchase *)aCYHP error:(NSInteger)aErrorCode message:(NSString*)aErrorMessage;

- (void)incompleteRestore:(CYHPurchase *)aCYHP;
- (void)failedRestore:(CYHPurchase *)aCYHP error:(NSInteger)aErrorCode message:(NSString*)aErrorMessage;


@end
