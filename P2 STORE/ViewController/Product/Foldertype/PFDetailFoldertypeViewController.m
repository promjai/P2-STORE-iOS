//
//  PFDetailFoldertypeViewController.m
//  Thaweeyont
//
//  Created by Pariwat Promjai on 11/4/2557 BE.
//  Copyright (c) 2557 Platwo fusion. All rights reserved.
//

#import "PFDetailFoldertypeViewController.h"

@interface PFDetailFoldertypeViewController ()

@end

@implementation PFDetailFoldertypeViewController

BOOL loadFolder;
BOOL noDataFolder;
BOOL refreshDataFolder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
        self.foldertypeOffline = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [self.obj objectForKey:@"name"];
    
    [self.view addSubview:self.waitView];
    [self startSpin];
    
    loadFolder = NO;
    noDataFolder = NO;
    refreshDataFolder = NO;
    
    self.arrObj = [[NSMutableArray alloc] init];
    
    self.Api = [[PFApi alloc] init];
    self.Api.delegate = self;
    
    [self.Api getFolderTypeByURL:[[self.obj objectForKey:@"node"] objectForKey:@"children"]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)startSpin
{
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

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
    if (finished)
    {
        
        [self startSpin];
        
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    refreshDataFolder = YES;
    [self.Api getFolderTypeByURL:[[self.obj objectForKey:@"node"] objectForKey:@"children"]];
    
}

- (void)PFApi:(id)sender getFolderTypeByURLResponse:(NSDictionary *)response {
    //NSLog(@"%@",response);
    
    [self.waitView removeFromSuperview];
    [self.refreshControl endRefreshing];
    
    if (!refreshDataFolder) {
        for (int i=0; i<[[response objectForKey:@"data"] count]; ++i) {
            [self.arrObj addObject:[[response objectForKey:@"data"] objectAtIndex:i]];
        }
    } else {
        [self.arrObj removeAllObjects];
        for (int i=0; i<[[response objectForKey:@"data"] count]; ++i) {
            [self.arrObj addObject:[[response objectForKey:@"data"] objectAtIndex:i]];
        }
    }
    
    if ( [[response objectForKey:@"paging"] objectForKey:@"next"] == nil ) {
        noDataFolder = YES;
    } else {
        noDataFolder = NO;
        self.paging = [[response objectForKey:@"paging"] objectForKey:@"next"];
    }
    
    [self.foldertypeOffline setObject:response forKey:[[self.obj objectForKey:@"node"] objectForKey:@"children"]];
    [self.foldertypeOffline synchronize];
    
    [self.tableView reloadData];
    
}

- (void)PFApi:(id)sender getFolderTypeByURLErrorResponse:(NSString *)errorResponse {
    NSLog(@"%@",errorResponse);
    
    [self.waitView removeFromSuperview];
    [self.refreshControl endRefreshing];
    
    if (!refreshDataFolder) {
        for (int i=0; i<[[[self.foldertypeOffline objectForKey:[[self.obj objectForKey:@"node"] objectForKey:@"children"]] objectForKey:@"data"] count]; ++i) {
            [self.arrObj addObject:[[[self.foldertypeOffline objectForKey:[[self.obj objectForKey:@"node"] objectForKey:@"children"]] objectForKey:@"data"] objectAtIndex:i]];
        }
    } else {
        [self.arrObj removeAllObjects];
        for (int i=0; i<[[[self.foldertypeOffline objectForKey:[[self.obj objectForKey:@"node"] objectForKey:@"children"]] objectForKey:@"data"] count]; ++i) {
            [self.arrObj addObject:[[[self.foldertypeOffline objectForKey:[[self.obj objectForKey:@"node"] objectForKey:@"children"]] objectForKey:@"data"] objectAtIndex:i]];
        }
    }
    
    [self.tableView reloadData];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrObj count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"folder"]) {
        
        PFFoldertypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PFFoldertypeCell"];
        if(cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PFFoldertypeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.thumbnails.layer.masksToBounds = YES;
        cell.thumbnails.contentMode = UIViewContentModeScaleAspectFill;
        
        NSString *urlimg = [[NSString alloc] initWithFormat:@"%@",[[[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"thumb"] objectForKey:@"url"]];
        
        [DLImageLoader loadImageFromURL:urlimg
                              completed:^(NSError *error, NSData *imgData) {
                                  cell.thumbnails.image = [UIImage imageWithData:imgData];
                              }];
        
        cell.name.text = [[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        return cell;
        
    } else {
        
        PFCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PFCatalogCell"];
        if(cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PFCatalogCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.thumbnails.layer.masksToBounds = YES;
        cell.thumbnails.contentMode = UIViewContentModeScaleAspectFill;
        
        NSString *urlimg = [[NSString alloc] initWithFormat:@"%@",[[[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"thumb"] objectForKey:@"url"]];
        
        [DLImageLoader loadImageFromURL:urlimg
                              completed:^(NSError *error, NSData *imgData) {
                                  cell.thumbnails.image = [UIImage imageWithData:imgData];
                              }];
        
        cell.name.text = [[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSString *price = [[NSString alloc] initWithFormat:@"%@ %@",[[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"price"],@"Baht"];
        cell.price.text = price;
        
        return cell;
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"item"]) {
        
        PFCatalogDetailViewController *catalogDetail = [[PFCatalogDetailViewController alloc] init];
        if(IS_WIDESCREEN) {
            catalogDetail = [[PFCatalogDetailViewController alloc] initWithNibName:@"PFCatalogDetailViewController_Wide" bundle:nil];
        } else {
            catalogDetail = [[PFCatalogDetailViewController alloc] initWithNibName:@"PFCatalogDetailViewController" bundle:nil];
        }
        self.navigationItem.title = @" ";
        catalogDetail.obj = [self.arrObj objectAtIndex:indexPath.row];
        catalogDetail.delegate = self;
        [self.navigationController pushViewController:catalogDetail animated:YES];
        
    } else if ([[[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"folder"]) {
        
        NSString *children_length = [[NSString alloc] initWithFormat:@"%@",[[self.arrObj objectAtIndex:indexPath.row] objectForKey:@"children_length"]];
        
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
            
            PFDetailFoldertype1ViewController *folderDetail = [[PFDetailFoldertype1ViewController alloc] init];
            if(IS_WIDESCREEN) {
                folderDetail = [[PFDetailFoldertype1ViewController alloc] initWithNibName:@"PFDetailFoldertype1ViewController_Wide" bundle:nil];
            } else {
                folderDetail = [[PFDetailFoldertype1ViewController alloc] initWithNibName:@"PFDetailFoldertype1ViewController" bundle:nil];
            }
            self.navigationItem.title = @" ";
            folderDetail.obj = [self.arrObj objectAtIndex:indexPath.row];
            folderDetail.delegate = self;
            [self.navigationController pushViewController:folderDetail animated:YES];
        }
        
    }
    
}

-(void)reload:(NSTimer *)timer
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float offset = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height));
    if (offset >= 0 && offset <= 5) {
        if (!noDataFolder) {
            refreshDataFolder = NO;
            
            [self.Api getFolderTypeByURL:[[self.obj objectForKey:@"node"] objectForKey:@"children"]];
        }
    }
}

- (void)PFGalleryViewController:(id)sender sum:(NSMutableArray *)sum current:(NSString *)current{
    [self.delegate PFGalleryViewController:self sum:sum current:current];
}

- (void)PFImageViewController:(id)sender viewPicture:(UIImage *)image{
    [self.delegate PFImageViewController:self viewPicture:image];
}

- (void)PFDetailFoldertype1ViewControllerBack {
    self.navigationItem.title = [self.obj objectForKey:@"name"];
    [self.tableView reloadData];
}

- (void)PFCatalogDetailViewControllerBack {
    self.navigationItem.title = [self.obj objectForKey:@"name"];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // 'Back' button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        if([self.delegate respondsToSelector:@selector(PFDetailFoldertypeViewControllerBack)]){
            [self.delegate PFDetailFoldertypeViewControllerBack];
        }
    }
}

@end
