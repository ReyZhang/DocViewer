//
//  DocListViewController.m
//  JhtTools
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jht on 16/7/8.
//  Copyright © 2016年 JhtDocViewer. All rights reserved.
//

#import "DocListViewController.h"
#import "JhtFileModel.h"
#import "LoadDocViewController.h"
#import "OtherOpenButtonParamModel.h"
#import "JhtShowDumpingViewParamModel.h"

/** 状态栏 + 导航栏的高度 */
#define KDLVCStatusAndNavBarHeight (KStatusBarHeight + KNavBarHeight)

@implementation DocListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    [self docLsSetNav];
    
    // 生成数据源
    [self docLsCreateSourceData];
    
    // CreateUI
    [self docLsCreateUI];
}


#pragma mark - SetNav
/** 设置导航栏 */
- (void)docLsSetNav {
    // 如果是 从appDelegate里面，跳转过来添加返回按钮
    if (_appFilePath.length) {
        // 设置导航栏返回按钮
        [self bsCreateNavigationBarLeftBtn];
    }
    
    // 设置导航栏标题
    [self bsCreateNavigationBarTitleViewWithLabelTitle:@"文件列表类"];
}


#pragma mark - Data
/** 生成数据源 */
- (void)docLsCreateSourceData {
    // 如果是 从appDelegate里面，跳转过来，主要用于打开别的软件的共享过来的文档
    if (_appFilePath.length) {
        JhtFileModel *model = [[JhtFileModel alloc] init];
        NSString *fileName = [_appFilePath lastPathComponent];
        model.fileName = fileName;
        model.fileAbsolutePath = _appFilePath;
        [_baseSourceArray addObject:model];
        
    } else {
        // 第一个是 网络的，需要下载的
        JhtFileModel *fileModel = [[JhtFileModel alloc] init];
        fileModel.fileId = @"577e2300c94f6e51316a299d";
        // **后缀就是文件格式，切记**
        fileModel.fileName = @"哈哈哈.docx";
        fileModel.viewFileType = Type_Docx;
        fileModel.url = @"http://mexue-inform-file.oss-cn-beijing.aliyuncs.com/577e2300c94f6e51316a299d";
//        fileModel.url = @"http://osyeryz0j.bkt.clouddn.com/jht-hljf-text/IPHONE%E6%89%8B%E6%9C%BAVPN%E9%85%8D%E7%BD%AE%E6%8C%87%E5%AF%BC.pdf";
        
        /*fileModel.fileName = @"赤壁.rtf";
        fileModel.viewFileType = Type_Txt;
        fileModel.url = @"http://pi4m2edox.bkt.clouddn.com/%E8%B5%A4%E5%A3%81.rtf";*/
        
        fileModel.fileSize = @"21.39KB";
        fileModel.attachmentFileSize = @"21906";
        [_baseSourceArray addObject:fileModel];
        
        // 总文件夹
        NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/JhtDoc/"]];
        
        // 文件管理器
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:folderPath]) return;
        // 从前向后枚举器
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
        // 详细内容
        NSString *fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil) {
//            NSLog(@"fileName ==== %@", fileName);
            NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//            NSLog(@"fileAbsolutePath ==== %@", fileAbsolutePath);
            JhtFileModel *model = [[JhtFileModel alloc] init];
            model.fileName  = fileName;
            model.fileAbsolutePath = fileAbsolutePath;
            [_baseSourceArray addObject:model];
        }
    }
}


#pragma mark - UI
/** CreateUI */
- (void)docLsCreateUI {
    _baseTableView.frame = CGRectMake(0, 0, FrameW, FrameH - KDLVCStatusAndNavBarHeight);
    
    _baseTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _baseTableView.backgroundColor = [UIColor colorWithRed:0.97f green:0.91f blue:0.89f alpha:1.00f];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _baseSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    JhtFileModel *model = [_baseSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.fileName;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

/** 改变左滑之后尾部文字内容 */
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    JhtFileModel *model = [_baseSourceArray objectAtIndex:indexPath.row];
    // 如果是本地的，从本地删除
    if (model.fileAbsolutePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:model.fileAbsolutePath error:nil];
    }
    // 移除数据源的数据
    [_baseSourceArray removeObjectAtIndex:indexPath.row];
    // 移除tableView中的数据
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 去除选中之后的效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LoadDocViewController *load = [[LoadDocViewController alloc] init];
    JhtFileModel *model = [_baseSourceArray objectAtIndex:indexPath.row];
    load.titleStr = model.fileName;
    load.currentFileModel = model;
    
    /*[load finishedDownloadCompletionHandler:^(NSString *urlStr) {
        NSLog(@"网络下载文件成功后保存在《本地的路径》: \n%@", urlStr);
    }];
    
    // 提示框Model
    JhtShowDumpingViewParamModel *paramModel = [[JhtShowDumpingViewParamModel alloc] init];
    paramModel.showTextFont = [UIFont boldSystemFontOfSize:15];
    paramModel.showBackgroundColor = [UIColor whiteColor];
    paramModel.showBackgroundImageName = @"dumpView";
    load.paramModel = paramModel;
    
    // 《用其他应用打开》按钮 配置Model
    OtherOpenButtonParamModel *otherOpenButtonParamModel = [[OtherOpenButtonParamModel alloc] init];
    otherOpenButtonParamModel.titleFont = [UIFont boldSystemFontOfSize:20.0];
    otherOpenButtonParamModel.backgroundColor = [UIColor purpleColor];
    load.otherOpenButtonParamModel = otherOpenButtonParamModel;
     */
    
    [self.navigationController pushViewController:load animated:YES];
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 避免dragImageView手势冲突 问题解决方法http://blog.sina.com.cn/s/blog_6b8c3d7a0101dxnc.html
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
        
    } else {
        return YES;
    }
}


@end
