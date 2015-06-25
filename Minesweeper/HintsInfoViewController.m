//
//  HintsInfoViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 6/18/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "HintsInfoViewController.h"
#import "MinesweeperIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface HintsInfoViewController()
@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;
@end

@implementation HintsInfoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.topViewController.title = @"Hints Info";
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restoreTapped:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reload {
    self.products = nil;
    [self.tableView reloadData];
    
    [[MinesweeperIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        if (success) {
            self.products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SKProduct *product = (SKProduct*)self.products[indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    [self.priceFormatter setLocale:product.priceLocale];
    cell.detailTextLabel.text = [self.priceFormatter stringFromNumber:product.price];
    
    //not a consumable product, and the identifier is not nil
    if (![[MinesweeperIAPHelper consumableProducts] containsObject:product.productIdentifier] && [[MinesweeperIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"  Buy  " forState:UIControlStateNormal];
        buyButton.layer.borderWidth = 1.0f;
        buyButton.layer.cornerRadius = 5;
        buyButton.layer.borderColor = [buyButton.tintColor CGColor];
        [buyButton sizeToFit];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    
    return cell;
}

#pragma mark - Other Functions
-(void)buyButtonTapped:(UIButton*)sender {
    
    UIButton *buyButton = sender;
    SKProduct *product = self.products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[MinesweeperIAPHelper sharedInstance] buyProduct:product];
}

-(void)productPurchased:(NSNotification *)notification {
    NSString * productIdentifier = notification.object;
    
    [self.products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

- (void)restoreTapped:(id)sender {
    [[MinesweeperIAPHelper sharedInstance] restoreCompletedTransactions];
}

#pragma mark - Lazy Instantiation
-(NSNumberFormatter*)priceFormatter {
    if (_priceFormatter) {
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    return _priceFormatter;
}

@end
