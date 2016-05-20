//
//  HotLineDepartmentViewController.m
//  AppPlant
//
//  Created by 曹军 on 16/5/3.
//  Copyright © 2016年 hogesoft. All rights reserved.
//

#import "HotLineDepartmentViewController.h"
#import "HotLineCell.h"
#import "HotLineView.h"
#import "HotlineTTTAttributedLabel.h"
#define  kHeightKey @"HeightKey"
#define  kModelKey @"kModelKey"
@interface HotLineDepartmentViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)HGTableView    * listTableView;
@property(nonatomic,strong)NSMutableArray    * departmentArray;
@property(nonatomic,strong)NSMutableDictionary * offscreenCells;
@property(nonatomic,strong)  NSCache * cellHeightCache;//缓存cell 高度
@end

@implementation HotLineDepartmentViewController
@synthesize listTableView;
@synthesize departmentArray;
@synthesize offscreenCells;
@synthesize cellHeightCache;
#pragma  mark - ViewCycle
-(void)dealloc
{
    listTableView.delegate = nil;
    listTableView.dataSource = nil;
    listTableView.refreshDelegate = nil;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.departmentArray =[NSMutableArray array];
        self.offscreenCells =[NSMutableDictionary dictionary];
        self.cellHeightCache =[[NSCache alloc]init];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTopView];
    self.headerTitle = @"问政部门";
    [self configureTableViewAndView];
    [self requestData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark - methods
-(CGFloat)loadCellHeightWithTableView:(UITableView*)tableView  heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //列表
    static NSString *listComponentIdentifier = @"HotLineDepartmentCell";
    HotLineDepartmentCell *  listComponentCell = [self.offscreenCells objectForKey:listComponentIdentifier];
    if (listComponentCell == nil)
    {
        
        listComponentCell = [[HotLineDepartmentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listComponentIdentifier];
        listComponentCell.backgroundColor=[UIColor clearColor];
        listComponentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!isNilNull(listComponentCell)) {
            [self.offscreenCells setObject:listComponentCell forKey:listComponentIdentifier];
        }
        
    }
    NSInteger index= indexPath.row;
    if (index < [departmentArray count]) {
        
        HotLineDepartmentModel * model =[departmentArray objectAtIndex:index];
        NSString *cachekey = [NSString stringWithFormat:@"%ld-%ld-%@-%@",(long)indexPath.section, (long)indexPath.row,model.departmentIdStr,model.departmentName];
        
        
        id object = [cellHeightCache objectForKey:cachekey];
        if (!isNilNull(object) && [object isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary * dict = object;
            NSString * heightStr =[dict objectForKey:kHeightKey];
            HotLineDepartmentModel  * cacheModel =[dict objectForKey:kModelKey];
            if ([cacheModel.departmentIdStr isEqualToString:model.departmentIdStr] && [cacheModel.departmentName isEqualToString:model.departmentName]) {
                if (!isNilNull(heightStr) && [heightStr isKindOfClass:[NSString class]]&&[heightStr length] && ![heightStr isEqualToString:@"0"]) {
                    return [heightStr floatValue];
                }
                
            }
        }
        
        [listComponentCell setNeedsUpdateConstraints];
        [listComponentCell updateConstraintsIfNeeded];
        [listComponentCell loadHotLineDepartmentSource:model];
        [listComponentCell setNeedsLayout];
        [listComponentCell layoutIfNeeded];
        ((UITableViewCell*)listComponentCell).contentView.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(((UITableViewCell*)listComponentCell).contentView.bounds));
        
        
        CGFloat height = [((UITableViewCell*)listComponentCell).contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        NSMutableDictionary * dict =[NSMutableDictionary dictionary];
        [dict setObject:[NSString stringWithFormat:@"%f",height] forKey:kHeightKey];
        if (!isNilNull(model)) {
            [dict setObject:model forKey:kModelKey];
        }
        [cellHeightCache setObject:dict forKey:cachekey];
        
        return height;
        
        
    }
    return 0;
    
    
}
-(void)configureTableViewAndView
{
    
    UIView* viewHeader = [self.view viewWithTag:kTagViewHeader];
    contentInsetsValue = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(viewHeader.frame.origin.y+viewHeader.frame.size.height, 0, 0, 0)];
    
    indicatorInsetsValue = contentInsetsValue;
    
    [attributes setValue:@(NO) forKey:HGRefreshShowTopAttributeName];
    
    [attributes setValue:@(NO) forKey:HGRefreshShowBottomAttributeName];
    
    if ([[HGAppDelegate template_Name] isEqualToString:AP_DEF_NAME1] && [self isRootViewController])
    {
        UIEdgeInsets contentInsets = [contentInsetsValue UIEdgeInsetsValue];
        contentInsetsValue = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(contentInsets.top, contentInsets.left, contentInsets.bottom+((AppDelegate *)HGAppDelegate).tabBarController.tabBar.frame.size.height, contentInsets.right)];
    }
    
    if (!isNilNull(indicatorInsetsValue)) {
        [attributes setValue:indicatorInsetsValue forKey:HGRefreshScrollIndicatorInsets];
    }
    
    if (!isNilNull(contentInsetsValue)) {
        [attributes setValue:contentInsetsValue forKey:HGRefreshContentInsets];
    }
    
    [attributes setValue:self.view.backgroundColor forKey:HGRefreshTopCoverColorAttributeName];
    [attributes setValue:self.view.backgroundColor forKey:HGRefreshBottomCoverColorAttributeName];
    HGTableView *  tableView  = [[HGTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain attributes:attributes];
    tableView.backgroundColor =[UIColor clearColor];
    tableView.refreshDelegate= nil;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view insertSubview:tableView belowSubview:viewHeader];
    self.listTableView = tableView;
}
#pragma mark - tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [departmentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *defaultCellIdentifier = @"HotLineDepartmenIdentifier";
    UITableViewCell *defaultCell  =(UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
    if (defaultCell == nil)
    {
        defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier];
        defaultCell.backgroundColor=[UIColor clearColor];
        defaultCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    
    
    static NSString *departmentListIdentifier = @"HotLineDepartmentCellIdentifier";
    HotLineDepartmentCell *departmentListCell  =(HotLineDepartmentCell*) [tableView dequeueReusableCellWithIdentifier:departmentListIdentifier];
    if (departmentListCell == nil)
    {
        departmentListCell = [[HotLineDepartmentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:departmentListIdentifier];
        departmentListCell.backgroundColor=[UIColor clearColor];
        departmentListCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    NSInteger index = indexPath.row;
    if (index < [departmentArray count]) {
        
        HotLineDepartmentModel * model =[departmentArray objectAtIndex:index];
        [departmentListCell setNeedsUpdateConstraints];
        [departmentListCell updateConstraintsIfNeeded];
        [departmentListCell loadHotLineDepartmentSource:model];
        [departmentListCell setNeedsLayout];
        [departmentListCell layoutIfNeeded];
        return departmentListCell;
        
    }
    return defaultCell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([departmentArray count]) {
        return  [self loadCellHeightWithTableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * vc =[[UIView alloc] initWithFrame:CGRectZero];
    vc.backgroundColor=[UIColor clearColor];
    return vc;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < [departmentArray count]) {
        HotLineDepartmentModel * model =[departmentArray objectAtIndex:indexPath.row];
        NSString *paramString =[NSString stringWithFormat:@"%@=%@",HGPARAMETERS_ID_KEY,model.departmentIdStr];
        NSString * defaultOutlink=   [[HGCommonConfigure sharedInstance]configureClassWithModelFlag:moduleSign prefixName:@"HotLineDepartmentChoose" withParamSources:paramString];
        NSDictionary * dic = nil;
        [Navigator  navigateToControllerWithCustomOutlink:defaultOutlink withOutlink:nil withNextStyle:dic withDataArray:nil shouldJump:YES];
    }
  
    
}
#pragma -mark NetData&Parse
-(void)requestData
{
    
    for (int i =0;i<20;i++) {
        HotLineDepartmentModel * model =[[HotLineDepartmentModel alloc]init];
        model.departmentThemeName = @"南京市工商管理局";
        model.departmentThemeNumber = @"1026";
        model.commnetName = @"已回复主题";
        model.commnetNumber = @"1028";
        model.departmentIdStr =[NSString stringWithFormat:@"%d",i];
        model.departmentName  =    [NSString stringWithFormat:@"测试测试测试测试测试测试测试试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测测试%d",i ];
        [departmentArray addObject:model];
        
    }
   
    [listTableView reloadTableView];
    
   
    
}
@end
