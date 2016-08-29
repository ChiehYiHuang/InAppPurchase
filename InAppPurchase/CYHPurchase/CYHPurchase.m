//
//  CYHPurchase.m
//  touchableearth
//
//  Created by ChiehYi Huang on 2015/5/18.
//  Copyright (c) 2015年 ChiehYi Huang. All rights reserved.
//

#import "CYHPurchase.h"

@implementation CYHPurchase

@synthesize delegate;
@synthesize validProduct;

- (BOOL)requestProduct:(NSString *)productId {
    if (productId != nil) {
        NSLog(@"RequestProduct: %@", productId);

        if ([SKPaymentQueue canMakePayments]) {
            SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
            productRequest.delegate = self;
            [productRequest start];
            
            return YES;
        } else {
            NSLog(@"Purchase requestProduct:IAP Disabled");
            
            [self alertView:@"Warning!" msg:@"IAP Disabled."];
            
            return NO;
        }
    } else {
        [self alertView:@"Warning!" msg:@"ProductId is nil"];
        
        return NO;
    }
}
- (BOOL)purchaseProduct:(SKProduct *)requestedProduct {
    if (requestedProduct != nil) {
        NSLog(@"PurchaseProduct: %@", requestedProduct.productIdentifier);
        if ([SKPaymentQueue canMakePayments]) {
            SKPayment *paymentRequest = [SKPayment paymentWithProduct:requestedProduct];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] addPayment:paymentRequest];
            
            return YES;
        } else {
            [self alertView:@"Warning!" msg:@"IAP Disabled."];
            
            return NO;
        }
    } else {
        [self alertView:@"Warning!" msg:@"ProductId is nil"];
        
        return NO;
    }
}
- (BOOL)restorePurchase {
    NSLog(@"RestorePurchase");
    
    if ([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        
        return YES;
    } else
        return NO;
}

#pragma mark - Private Function
- (void)alertView:(NSString *)aTitle msg:(NSString *)aMsg {
    [[[UIAlertView alloc] initWithTitle:aTitle
                                message:aMsg
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)aRequest didReceiveResponse:(SKProductsResponse *)aResponse {

    self.validProduct = nil;
    int count = (int)[aResponse.products count];
    if (count > 0) {
        self.validProduct = [aResponse.products objectAtIndex:0];
    }
    if (self.validProduct) {
        [delegate requestedProduct:self
                        identifier:self.validProduct.productIdentifier
                              name:self.validProduct.localizedTitle
                             price:[self.validProduct.price stringValue]
                       description:self.validProduct.localizedDescription];
        
    } else {
        [delegate requestedProduct:self
                        identifier:nil
                              name:nil
                             price:nil
                       description:nil];
    }

}

#pragma mark - SKPaymentTransactionObserver
// The transaction status of the SKPaymentQueue is sent here.
- (void)paymentQueue:(SKPaymentQueue *)aQueue updatedTransactions:(NSArray *)aTransactions  {
    for(SKPaymentTransaction *transaction in aTransactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateDeferred:
                // Item is still in the process of being purchased
                break;
            case SKPaymentTransactionStatePurchasing:
                // Item is still in the process of being purchased
                break;
            case SKPaymentTransactionStatePurchased:
                // Item was successfully purchased!
                
                // Return transaction data. App should provide user with purchased product.
                [delegate successfulPurchase:self
                                  identifier:transaction.payment.productIdentifier
                                     receipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]]];
                
                // After customer has successfully received purchased content,
                // remove the finished transaction from the payment queue.
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                // Verified that user has already paid for this item.
                // Ideal for restoring item across all devices of this customer.
                
                // Return transaction data. App should provide user with purchased product.
                [delegate successfulPurchase:self
                                  identifier:transaction.payment.productIdentifier
                                     receipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]]];
                
                // After customer has restored purchased content on this device,
                // remove the finished transaction from the payment queue.
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                // Purchase was either cancelled by user or an error occurred.
                
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    // A transaction error occurred, so notify user.
                    
                    [delegate failedPurchase:self
                                       error:transaction.error.code
                                     message:transaction.error.localizedDescription];
                }
                // Finished transactions should be removed from the payment queue.
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}
// Called when one or more transactions have been removed from the queue.
- (void)paymentQueue:(SKPaymentQueue *)aQueue removedTransactions:(NSArray *)aTransactions {
    NSLog(@"RemovedTransactions");
    
    // Release the transaction observer since transaction is finished / removed.
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
// Called when SKPaymentQueue has finished sending restored transactions.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"PaymentQueueRestoreCompletedTransactionsFinished");
    
    if ([queue.transactions count] == 0) {
        // Queue does not include any transactions, so either user has not yet made a purchase
        // or the user's prior purchase is unavailable, so notify app (and user) accordingly.
        
        NSLog(@"Restore queue.transactions count == 0");
        
        [self alertView:@"提醒" msg:@"無待恢復之項目。"];
        
        // Release the transaction observer since no prior transactions were found.
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
        
        [delegate incompleteRestore:self];
        
    } else {
        // Queue does contain one or more transactions, so return transaction data.
        // App should provide user with purchased product.
        NSLog(@"Restore queue.transactions available");
        
        for(SKPaymentTransaction *transaction in queue.transactions) {
            NSLog(@"Restore queue.transactions - transaction data found");
            
            [delegate successfulPurchase:self
                              identifier:transaction.payment.productIdentifier
                                 receipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]]];
        }
    }
}
// Called if an error occurred while restoring transactions.
- (void)paymentQueue:(SKPaymentQueue *)aQueue restoreCompletedTransactionsFailedWithError:(NSError *)aError {
    // Restore was cancelled or an error occurred, so notify user.
    NSLog(@"RestoreCompletedTransactionsFailedWithError");
    
    [delegate failedRestore:self
                      error:aError.code
                    message:aError.localizedDescription];
}

@end
