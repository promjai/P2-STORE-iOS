//
//  PFProductViewController.m
//  thaweeyont
//
//  Created by Promjai on 10/14/2557 BE.
//  Copyright (c) 2557 Platwo fusion. All rights reserved.
//

#import "PFProductViewController.h"

@interface PFProductViewController ()

@end

@implementation PFProductViewController

BOOL loadProduct;
BOOL noDataProduct;
BOOL refreshDataProduct;

int productInt;
NSTimer *timmer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
        self.catalogOffline = [NSUserDefaults standardUserDefaults];
        self.promotionOffline = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:self.waitView];
    [self startSpin];
    
    self.Api = [[PFApi alloc] init];
    self.Api.delegate = self;
    
    if (![[self.Api getLanguage] isEqualToString:@"TH"]) {
        [self.segmented setTitle:@"Promotion" forSegmentAtIndex:0];
        [self.segmented setTitle:@"Catalog" forSegmentAtIndex:1];
    } else {
        [self.segmented setTitle:@"โปรโมชั่น" forSegmentAtIndex:0];
        [self.segmented setTitle:@"แคตตาล็อก" forSegmentAtIndex:1];
    }
    
    // Navbar setup
    [[self.navController navigationBar] setBarTintColor:[UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f]];
    
    [[self.navController navigationBar] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[self.navController navigationBar] setTranslucent:YES];
    [self.view addSubview:self.navController.view];
    
    self.checksegmented = @"0";
    [self.segmented addTarget:self
                       action:@selector(segmentselect:)
             forControlEvents:UIControlEventValueChanged];
    
    //UIView *hv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    UIView *fv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //self.promotiontableView.tableHeaderView = hv;
    self.promotiontableView.tableFooterView = fv;
    
    [self.mainView addSubview:self.promotionView];
    
    [self.Api getPromotion:@"15" link:@"NO"];
    
    [self.promotionOffline setObject:@"0" forKey:@"promotion_updated"];
    [self.catalogOffline setObject:@"0" forKey:@"catalog_updated"];
    
    self.arrObjCatalog = [[NSMutableArray alloc] init];
    self.arrObjPromotion = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)startSpin
{
    self.statusProgress = @"startSpin";
    
    if (!self.popupProgressBar) {
        
        if(IS_WIDESCREEN) {
            self.popupProgressBar = [[UIImageView alloc] initWithFrame:CGRectMake(145, 269, 30, 30)];
            self.popupProgressBar.image = [UIImage imageNamed:@"ic_loading"];
            [self.waitView addSubview:self.popupProgressBar];
        } else {
            self.popupProgressBar = [[UIImageView alloc] initWithFrame:CGRectMake(145, 225, 30, 30)];
            self.popupProgressBar.image = [UIImage imageNamed:@"ic_loading"];
            [self.waitView addSubview:self.popupProgressBar];
        }
        
    }
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGRect frame = [self.popupProgressBar frame];
    self.popupProgressBar.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.popupProgressBar.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    [CATransaction setValue:[NSNumber numberWithFloat:1.0] forKey:kCATransactionAnimationDuration];
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.delegate = self;
    [self.popupProgressBar.layer addAnimation:animation forKey:@"rotationAnimation"];
    
    [CATransaction commit];
}

- (void)startPullToRefresh
{
    
    self.statusProgress = @"startPullToRefresh";
    
    if (!self.progressBar) {
        
        self.progressBar = [[UIImageView alloc] initWithFrame:CGRectMake(150, 81, 20, 20)];
        self.progressBar.image = [UIImage imageNamed:@"ic_loading"];
        [self.view addSubview:self.progressBar];
        
    }
    
    self.progressBar.hidden = NO;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGRect frame = [self.progressBar frame];
    self.progressBar.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.progressBar.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    [CATransaction setValue:[NSNumber numberWithFloat:1.0] forKey:kCATransactionAnimationDuration];
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.delegate = self;
    [self.progressBar.layer addAnimation:animation forKey:@"rotationAnimation"];
    
    [CATransaction commit];
}

- (void)stopPullToRefresh
{
    [self.progressBar.layer removeAllAnimations];
    self.progressBar.hidden = YES;
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

/* Called when the animation either completes its active duration or
 * is removed from the object it is attached to (i.e. the layer). 'flag'
 * is true if the animation reached the end of its active duration
 * without being removed. */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
    if (finished)
    {
        
        if ([self.statusProgress isEqualToString:@"startSpin"]) {
            [self startSpin];
        } else {
            [self startPullToRefresh];
        }
        
    }
}

- (void)segmentselect:(id)sender {

    if (self.segmented.selectedSegmentIndex == 0) {
        self.checksegmented = @"0";
        
        UIView *fv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.promotiontableView.tableFooterView = fv;
        
        [self.catalogView removeFromSuperview];
        [self.mainView addSubview:self.promotionView];
        
        [self.Api getPromotion:@"15" link:@"NO"];
    }
    if (self.segmented.selectedSegmentIndex == 1) {
        self.checksegmented = @"1";
        
        UIView *hv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        UIView *fv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.catalogtableView.tableHeaderView = hv;
        self.catalogtableView.tableFooterView = fv;
        
        [self.promotionView removeFromSuperview];
        [self.mainView addSubview:self.catalogView];
        
        [self.Api getCatalog:@"15" link:@"NO"];
        
    }
    
}

- (void)PFApi:(id)sender getPromotionResponse:(NSDictionary *)response {
    //NSLog(@"%@",response);
    
    [self.waitView removeFromSuperview];
    
    [self.NoInternetView removeFromSuperview];
    self.checkinternet = @"connect";
    
    self.objPromotion = response;
    
    if (!refreshDataProduct) {
        [self.arrObjPromotion removeAllObjects];
        for (int i=0; i<[[response objectForKey:@"data"] count]; ++i) {
            [self.arrObjPromotion addObject:[[response objectForKey:@"data"] objectAtIndex:i]];
        }
    } else {
        [self.arrObjPromotion removeAllObjects];
        for (int i=0; i<[[response objectForKey:@"data"] count]; ++i) {
            [self.arrObjPromotion addObject:[[response objectForKey:@"data"] objectAtIndex:i]];
        }
    }
    
    if ( [[response objectForKey:@"paging"] objectForKey:@"next"] == nil ) {
        noDataProduct = YES;
    } else {
        noDataProduct = NO;
        self.paging = [[response objectForKey:@"paging"] objectForKey:@"next"];
    }
    
    [self.promotionOffline setObject:response forKey:@"promotionArray"];
    [self.promotionOffline synchronize];
    
    if ([[self.promotionOffline objectForKey:@"promotion_updated"] intValue] != [[response objectForKey:@"last_updated"] intValue]) {
        [self reloadData:YES];
        [self.promotionOffline setObject:[response objectForKey:@"last_updated"] forKey:@"promotion_updated"];
    }
}

- (void)PFApi:(id)sender getPromotionErrorResponse:(NSString *)errorResponse {
    NSLog(@"%@",errorResponse);
    
    [self.waitView removeFromSuperview];
    
    self.checkinternet = @"error";
    self.NoInternetView.frame = CGRectMake(0, 64, self.NoInternetView.frame.size.width, self.NoInternetView.frame.size.height);
    [self.view addSubview:self.NoInternetView];
    
    productInt = 5;
    timmer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    if (!refreshDataProduct) {
        [self.arrObjPromotion removeAllObjects];
        for (int i=0; i<[[[self.promotionOffline objectForKey:@"promotionArray"] objectForKey:@"data"] count]; ++i) {
            [self.arrObjPromotion addObject:[[[self.promotionOffline objectForKey:@"promotionArray"] objectForKey:@"data"] objectAtIndex:i]];
        }
    } else {
        [self.arrObjPromotion removeAllObjects];
        for (int i=0; i<[[[self.promotionOffline objectForKey:@"promotionArray"] objectForKey:@"data"] count]; ++i) {
            [self.arrObjPromotion addObject:[[[self.promotionOffline objectForKey:@"promotionArray"] objectForKey:@"data"] objectAtIndex:i]];
        }
    }
    
    if ([[self.promotionOffline objectForKey:@"promotion_updated"] intValue] != [[[self.promotionOffline objectForKey:@"promotionArray"] objectForKey:@"last_updated"] intValue]) {
        [self reloadData:YES];
        [self.promotionOffline setObject:[[self.promotionOffline objectForKey:@"promotionArray"] objectForKey:@"last_updated"] forKey:@"promotion_updated"];
    }
    
}

- (void)PFApi:(id)sender getCatalogResponse:(NSDictionary *)response {
    //NSLog(@"%@",response);
    
    [self.waitView removeFromSuperview];
    
    [self.NoInternetView removeFromSuperview];
    self.checkinternet = @"connect";
    
    self.objCatalog = response;
    
    if (!refreshDataProduct) {
        [self.arrObjCatalog removeAllObjects];
        for (int i=0; i<[[response objectForKey:@"data"] count]; ++i) {
            [self.arrObjCatalog addObject:[[response objectForKey:@"data"] objectAtIndex:i]];
        }
    } else {
        [self.arrObjCatalog removeAllObjects];
        for (int i=0; i<[[response objectForKey:@"data"] count]; ++i) {
            [self.arrObjCatalog addObject:[[response objectForKey:@"data"] objectAtIndex:i]];
        }
    }
    
    if ( [[response objectForKey:@"paging"] objectForKey:@"next"] == nil ) {
        noDataProduct = YES;
    } else {
        noDataProduct = NO;
        self.paging = [[response objectForKey:@"paging"] objectForKey:@"next"];
    }
    
    [self.catalogOffline setObject:response forKey:@"catalogArray"];
    [self.catalogOffline synchronize];
    
    if ([[self.catalogOffline objectForKey:@"catalog_updated"] intValue] != [[response objectForKey:@"last_updated"] intValue]) {
        [self reloadData:YES];
        [self.catalogOffline setObject:[response objectForKey:@"last_updated"] forKey:@"catalog_updated"];
    }
    
}

- (void)PFApi:(id)sender getCatalogErrorResponse:(NSString *)errorResponse {
    NSLog(@"%@",errorResponse);
    
    [self.waitView removeFromSuperview];
    
    self.checkinternet = @"error";
    self.NoInternetView.frame = CGRectMake(0, 64, self.NoInternetView.frame.size.width, self.NoInternetView.frame.size.height);
    [self.view addSubview:self.NoInternetView];
    
    productInt = 5;
    timmer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    if (!refreshDataProduct) {
        [self.arrObjCatalog removeAllObjects];
        for (int i=0; i<[[[self.catalogOffline objectForKey:@"catalogArray"] objectForKey:@"data"] count]; ++i) {
            [self.arrObjCatalog addObject:[[[self.catalogOffline objectForKey:@"catalogArray"] objectForKey:@"data"] objectAtIndex:i]];
        }
    } else {
        [self.arrObjCatalog removeAllObjects];
        for (int i=0; i<[[[self.catalogOffline objectForKey:@"catalogArray"] objectForKey:@"data"] count]; ++i) {
            [self.arrObjCatalog addObject:[[[self.catalogOffline objectForKey:@"catalogArray"] objectForKey:@"data"] objectAtIndex:i]];
        }
    }
    
    if ([[self.catalogOffline objectForKey:@"catalog_updated"] intValue] != [[[self.catalogOffline objectForKey:@"catalogArray"] objectForKey:@"last_updated"] intValue]) {
        [self reloadData:YES];
        [self.catalogOffline setObject:[[self.catalogOffline objectForKey:@"catalogArray"] objectForKey:@"last_updated"] forKey:@"catalog_updated"];
    }
    
}

- (void)countDown {
    productInt -= 1;
    if (productInt == 0) {
        [self.NoInternetView removeFromSuperview];
    }
}

- (void)reloadData:(BOOL)animated
{
    [self.promotiontableView reloadData];
    [self.catalogtableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.checksegmented isEqualToString:@"0"]) {
        return [self.arrObjPromotion count];
    } else {
        return [self.arrObjCatalog count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  92;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.checksegmented isEqualToString:@"0"]) {
        
        PFPromotionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PFPromotionCell"];
        if(cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PFPromotionCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.thumbnails.layer.masksToBounds = YES;
        cell.thumbnails.contentMode = UIViewContentModeScaleAspectFill;
        
        NSString *urlimg = [[NSString alloc] initWithFormat:@"%@",[[[self.arrObjPromotion objectAtIndex:indexPath.row] objectForKey:@"thumb"] objectForKey:@"url"]];
        
        [DLImageLoader loadImageFromURL:urlimg
                              completed:^(NSError *error, NSData *imgData) {
                                  cell.thumbnails.image = [UIImage imageWithData:imgData];
                              }];
        
        cell.name.text = [[self.arrObjPromotion objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detail.text = [[self.arrObjPromotion objectAtIndex:indexPath.row] objectForKey:@"detail"];
        
        return cell;
        
    } else {
        
        if ([[[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"folder"]) {
            
            PFFoldertypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PFFoldertypeCell"];
            if(cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PFFoldertypeCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            cell.thumbnails.layer.masksToBounds = YES;
            cell.thumbnails.contentMode = UIViewContentModeScaleAspectFill;
            
            NSString *urlimg = [[NSString alloc] initWithFormat:@"%@",[[[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"thumb"] objectForKey:@"url"]];
            
            [DLImageLoader loadImageFromURL:urlimg
                                  completed:^(NSError *error, NSData *imgData) {
                                      cell.thumbnails.image = [UIImage imageWithData:imgData];
                                  }];
            
            cell.name.text = [[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"name"];
            
            return cell;
        
        } else {
            
            PFCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PFCatalogCell"];
            if(cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PFCatalogCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            cell.thumbnails.layer.masksToBounds = YES;
            cell.thumbnails.contentMode = UIViewContentModeScaleAspectFill;
            
            NSString *urlimg = [[NSString alloc] initWithFormat:@"%@",[[[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"thumb"] objectForKey:@"url"]];
            
            [DLImageLoader loadImageFromURL:urlimg
                                  completed:^(NSError *error, NSData *imgData) {
                                      cell.thumbnails.image = [UIImage imageWithData:imgData];
                                  }];
            
            cell.name.text = [[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"name"];
            NSString *price = [[NSString alloc] initWithFormat:@"%@ %@",[[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"price"],@"Baht"];
            cell.price.text = price;
            
            return cell;
        
        }
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.NoInternetView removeFromSuperview];
    
    if ([self.checksegmented isEqualToString:@"0"]) {
        
        [self.delegate HideTabbar];
        
        PFPromotionDetailViewController *promotionDetail = [[PFPromotionDetailViewController alloc] init];
        if(IS_WIDESCREEN) {
            promotionDetail = [[PFPromotionDetailViewController alloc] initWithNibName:@"PFPromotionDetailViewController_Wide" bundle:nil];
        } else {
            promotionDetail = [[PFPromotionDetailViewController alloc] initWithNibName:@"PFPromotionDetailViewController" bundle:nil];
        }
        self.navItem.title = @" ";
        promotionDetail.obj = [self.arrObjPromotion objectAtIndex:indexPath.row];
        promotionDetail.delegate = self;
        [self.navController pushViewController:promotionDetail animated:YES];
        
    } else {
        
        if ([[[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"folder"]) {
            
            NSString *children_length = [[NSString alloc] initWithFormat:@"%@",[[self.arrObjCatalog objectAtIndex:indexPath.row] objectForKey:@"children_length"]];
            
            if ([children_length isEqualToString:@"0"]) {
                
                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reload:) userInfo:nil repeats:NO];
                
                if (![[self.Api getLanguage] isEqualToString:@"TH"]) {
                    [[[UIAlertView alloc] initWithTitle:@"ทวียนต์!"
                                                message:@"Coming soon."
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"ทวียนต์!"
                                                message:@"เร็วๆ นี้."
                                               delegate:nil
                                      cancelButtonTitle:@"ตกลง"
                                      otherButtonTitles:nil] show];
                }
                
            } else {
                [self.delegate HideTabbar];
                
                PFDetailFoldertypeViewController *folderDetail = [[PFDetailFoldertypeViewController alloc] init];
                if(IS_WIDESCREEN) {
                    folderDetail = [[PFDetailFoldertypeViewController alloc] initWithNibName:@"PFDetailFoldertypeViewController_Wide" bundle:nil];
                } else {
                    folderDetail = [[PFDetailFoldertypeViewController alloc] initWithNibName:@"PFDetailFoldertypeViewController" bundle:nil];
                }
                self.navItem.title = @" ";
                folderDetail.obj = [self.arrObjCatalog objectAtIndex:indexPath.row];
                folderDetail.delegate = self;
                [self.navController pushViewController:folderDetail animated:YES];
            }
            
        
        } else {
            
            [self.delegate HideTabbar];
            
            PFCatalogDetailViewController *catalogDetail = [[PFCatalogDetailViewController alloc] init];
            if(IS_WIDESCREEN) {
                catalogDetail = [[PFCatalogDetailViewController alloc] initWithNibName:@"PFCatalogDetailViewController_Wide" bundle:nil];
            } else {
                catalogDetail = [[PFCatalogDetailViewController alloc] initWithNibName:@"PFCatalogDetailViewController" bundle:nil];
            }
            self.navItem.title = @" ";
            catalogDetail.obj = [self.arrObjCatalog objectAtIndex:indexPath.row];
            catalogDetail.delegate = self;
            [self.navController pushViewController:catalogDetail animated:YES];
            
        }
    
    }
}

-(void)reload:(NSTimer *)timer
{
    [self.catalogtableView reloadData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"%f",scrollView.contentOffset.y);
    //[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ( scrollView.contentOffset.y < 0.0f ) {
        //NSLog(@"refreshData < 0.0f");
        
        [self stopPullToRefresh];
        
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"%f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -60.0f ) {
        refreshDataProduct = YES;
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if ( scrollView.contentOffset.y < -100.0f ) {
        
        if ([self.checksegmented isEqualToString:@"0"]) {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0];
            self.promotiontableView.frame = CGRectMake(0, 60, self.promotiontableView.frame.size.width, self.promotiontableView.frame.size.height);
            [UIView commitAnimations];
            [self performSelector:@selector(resizeTable) withObject:nil afterDelay:2];
            
            [self startPullToRefresh];
            
        } else {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0];
            self.catalogtableView.frame = CGRectMake(0, 60, self.catalogtableView.frame.size.width, self.catalogtableView.frame.size.height);
            [UIView commitAnimations];
            [self performSelector:@selector(resizeTable) withObject:nil afterDelay:2];
            
            [self startPullToRefresh];
            
        }

    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float offset = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height));
    if (offset >= 0 && offset <= 5) {
        if (!noDataProduct) {
            refreshDataProduct = NO;
            
            if ([self.checksegmented isEqualToString:@"0"]) {
                
                if ([self.checkinternet isEqualToString:@"connect"]) {
                    [self.Api getPromotion:@"NO" link:self.paging];
                }
                
            } else {
                
                if ([self.checkinternet isEqualToString:@"connect"]) {
                    [self.Api getCatalog:@"NO" link:self.paging];
                }
                
            }
            
        }
    }
}

- (void)resizeTable {
    
    if ([self.checksegmented isEqualToString:@"0"]) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.promotiontableView.frame = CGRectMake(0, 0, self.promotiontableView.frame.size.width, self.promotiontableView.frame.size.height);
        [UIView commitAnimations];
        
    } else {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.catalogtableView.frame = CGRectMake(0, 0, self.catalogtableView.frame.size.width, self.catalogtableView.frame.size.height);
        [UIView commitAnimations];
        
    }
    
    [self stopPullToRefresh];
    
}

//full image
- (void)PFGalleryViewController:(id)sender sum:(NSMutableArray *)sum current:(NSString *)current{
    [self.delegate PFGalleryViewController:self sum:sum current:current];
}

- (void)PFImageViewController:(id)sender viewPicture:(UIImage *)image {
    [self.delegate PFImageViewController:self viewPicture:image];
}

//back to contact page

- (void)PFPromotionDetailViewControllerBack {
    [self.delegate ShowTabbar];
    [self reloadData:YES];
}

- (void)PFCatalogDetailViewControllerBack {
    [self.delegate ShowTabbar];
    [self reloadData:YES];
}

- (void)PFDetailFoldertypeViewControllerBack {
    [self.delegate ShowTabbar];
    [self reloadData:YES];
}

@end
