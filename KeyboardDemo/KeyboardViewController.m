//
//  KeyboardViewController.m
//  KeyboardDemo
//
//  Created by hello on 2019/10/19.
//  Copyright © 2019 Dio. All rights reserved.
//

#import "KeyboardViewController.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width

@interface KeyboardViewController ()
@property (nonatomic, strong) NSMutableArray<NSString *> *firstButtonRow;//第一行字母
@property (nonatomic, strong) NSMutableArray<NSString *> *secondButtonRow;//第二行字母
@property (nonatomic, strong) NSMutableArray<NSString *> *thirdButtonRow;//第三行字母
@property (nonatomic, strong) NSMutableArray<NSString *> *forthButtonRow;//第四行字母
@property (nonatomic, strong) NSMutableArray<NSMutableArray<UIButton*>*> *allButtons;//存放四组 按钮数组
@property (nonatomic) BOOL isPressShiftKey;//大小写
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allButtons = [NSMutableArray array];
    self.isPressShiftKey = NO;
    
    self.firstButtonRow = [NSMutableArray arrayWithObjects:@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p", nil];
    self.secondButtonRow = [NSMutableArray arrayWithObjects:@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l", nil];
    self.thirdButtonRow = [NSMutableArray arrayWithObjects:@"cp",@"z",@"x",@"c",@"v",@"b",@"n",@"m",@"dp", nil];
    self.forthButtonRow = [NSMutableArray arrayWithObjects:@"123",@"next",@"Space",@"ch/en",@"return", nil];
    
    UIView *FirstRow = [self createRowOfButtons:self.firstButtonRow];
    UIView *SecndRow = [self createRowOfButtons:self.secondButtonRow];
    UIView *ThirdRow = [self createRowOfButtons:self.thirdButtonRow];
    UIView *forthRow = [self createRowOfButtons:self.forthButtonRow];
    NSArray *rows = @[FirstRow,SecndRow,ThirdRow,forthRow];
    
    [self.view addSubview:FirstRow];
    [self.view addSubview:SecndRow];
    [self.view addSubview:ThirdRow];
    [self.view addSubview:forthRow];
    [self addRowsLayoutConstraint:rows andView:self.view];
}


//添加按键，并且对按钮进行设置
- (UIButton *)createButtonWithTitle:(NSString *)title{
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    button.frame = CGRectMake(0, 0, 80, 80);
    [button setTitle:title forState:(UIControlStateNormal)];
    [button sizeToFit];
    button.titleLabel.font = [UIFont systemFontOfSize:30];
    [button setTranslatesAutoresizingMaskIntoConstraints:false];
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:(UIControlEventTouchUpInside)];
    //设置button.layer为圆角
    button.layer.cornerRadius = 3;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    return button;
}
//创建一行button
- (UIView *)createRowOfButtons:(NSArray*)buttonTitles{
    NSMutableArray* buttons = [NSMutableArray array];
    //行视图宽高
    UIView* keyBoardRowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 70)];
    //遍历button
    for (NSString *title in buttonTitles) {
        //调用createButtonWithTitle
        UIButton *button = [self createButtonWithTitle:title];
        //将button添加到数组中
        [buttons addObject:button];
        [keyBoardRowView addSubview:button];
    }
    [self.allButtons addObject:buttons];
    //调用约束
    [self addButtonLayoutConstraint:buttons andView:keyBoardRowView];
    return keyBoardRowView;
}


//获取点击按钮的title
- (void)didTapButton:(UIButton*)sender{
    NSString* title = [sender titleForState:UIControlStateNormal];
    //响应触摸事件的文本内容
    if ([title isEqualToString:@"cp"] || [title isEqualToString:@"CP"]) {
        self.isPressShiftKey = !self.isPressShiftKey;
        //大小写转换
        [self changeUpOrDown:sender];
    }else if ([title isEqualToString:@"dp"] || [title isEqualToString:@"DP"]){
        [self.textDocumentProxy deleteBackward];//后退删除
    }else if ([title isEqualToString:@"Space"]){
        [self.textDocumentProxy insertText:@" "];//输入空格
    }else if ([title isEqualToString:@"return"]){
        [self.textDocumentProxy insertText:@"\n"];//换行
    }else if ([title isEqualToString:@"next"]){
        [self advanceToNextInputMode];//切换其他键盘
    }else{
        if ([title isEqualToString:@"Z"]) {
            [self dismissKeyboard];//隐藏键盘
        }
        [self.textDocumentProxy insertText:title];//将所点击按钮上的标题插入文本
    }
}
//大小写转换
- (void)changeUpOrDown:(UIButton *)shiftKey{
    for (int i =0; i < self.allButtons.count - 1; i++) {
        NSArray * buttons = [self.allButtons objectAtIndex:i];
        for (UIButton *button in buttons) {
            NSString *title = [button titleForState:UIControlStateNormal];
            if (self.isPressShiftKey) {
                title = [title uppercaseString];
            }else{
                title = [title lowercaseString];
            }
            [button setTitle:title forState:(UIControlStateNormal)];
        }
    }
}

//button约束
-(void)addButtonLayoutConstraint:(NSMutableArray*)buttons andView:(UIView*)keyboardView{
    for (UIButton *button in buttons) {
        //边距
        NSInteger space = 0;
        NSInteger index = [buttons indexOfObject:button];
        //关闭button自动翻译约束的功能
        button.translatesAutoresizingMaskIntoConstraints = NO;
        //万能代码约束
        //顶部约束
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:keyboardView attribute:NSLayoutAttributeTop multiplier:1.0 constant:space];
        //底部约束
        NSLayoutConstraint *buttomConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:keyboardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-space];
        //右边约束
        NSLayoutConstraint *rightConstraint = nil;
        //右边约束
        NSLayoutConstraint *leftConstraint = nil;
        //判读最后一个button
        if (index == buttons.count - 1) {
            rightConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:keyboardView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-space];
        }
        else{
            //当前button的下一个button的右约束
            UIButton *nextButton = buttons[index + 1];
            rightConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:nextButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-space];
        }
        //左约束
        if (index == 0) {
            leftConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:keyboardView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:space];
        }
        else{
            UIButton *prevtButton = buttons[index - 1];
            leftConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:prevtButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:space];
        }
        //等宽
        UIButton *firstButton = buttons[0];
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:firstButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        [keyboardView addConstraint:widthConstraint];
        
        [keyboardView addConstraints:@[topConstraint,buttomConstraint,rightConstraint,leftConstraint]];
    }
}

//row约束
-(void)addRowsLayoutConstraint:(NSArray*)rows andView:(UIView*)inputView{
    for (UIView *rowView in rows) {
        NSInteger space = 0;
        NSInteger index = [rows indexOfObject:rowView];
        rowView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-space];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:space];
        //顶部约束
        NSLayoutConstraint *topConstraint = nil;
        if (index == 0) {
            topConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        }
        else{
            UIView *prevtRow = rows[index - 1];
            topConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:prevtRow attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        }
        //底部约束
        NSLayoutConstraint *buttomConstraint = nil;
        if (index == rows.count - 1) {
            buttomConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:inputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        }
        else{
            UIView *nextRow = rows[index + 1];
            buttomConstraint = [NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:nextRow attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        }
        //等高约束
        UIView *firstRow = rows[0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:firstRow attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rowView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        [inputView addConstraint:heightConstraint];
        
        [inputView addConstraints:@[leftConstraint,rightConstraint,topConstraint,buttomConstraint]];
    }
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
}

@end
