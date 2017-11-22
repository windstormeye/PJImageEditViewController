//
//  PJEditImageTouchView.m
//  editImageTest
//
//  Created by pjpjpj on 2017/11/21.
//  Copyright © 2017年 #incloud. All rights reserved.
//

#import "PJEditImageTouchView.h"
#import "PJEditImageStroke.h"

@interface PJEditImageTouchView()

// 是否擦除（橡皮擦功能）
@property (nonatomic, assign) BOOL isEarse;
// 存储所有的画笔路径
@property (nonatomic, strong) NSMutableArray *stroks;
// 画笔颜色
@property (nonatomic, strong) UIColor *lineColor;
// 线条宽度
@property (nonatomic, assign) CGFloat lineWidth;
// 马赛克显示层
@property (nonatomic, strong) CALayer *imageLayer;
// 马赛克显示层的遮罩
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
// 当前手指的路径点集合
@property (nonatomic,assign)CGMutablePathRef blurPath;
// 存储每次手指移动过的路径点
@property(nonatomic,strong)NSMutableArray * appendPaths;
// 储存所有的路径点
@property(nonatomic,strong)NSMutableArray * allPaths;

@end

@implementation PJEditImageTouchView {
    CGMutablePathRef currentPath;//路径
}

- (NSMutableArray *)allPaths {
    if (!_allPaths) {
        _allPaths = [NSMutableArray array];
    }
    return _allPaths;
}

- (NSMutableArray *)appendPaths {
    if (!_appendPaths) {
        _appendPaths = [NSMutableArray array];
    }
    return _appendPaths;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _stroks = [[NSMutableArray alloc] initWithCapacity:1];
        self.blurPath = CGPathCreateMutable();
        self.backgroundColor = [UIColor clearColor];

        self.imageLayer = [CALayer layer];
        self.imageLayer.frame = self.bounds;
        [self.layer addSublayer:self.imageLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = self.bounds;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.lineJoin = kCALineJoinRound;
        self.shapeLayer.lineWidth = 10.f;
        self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        self.shapeLayer.fillColor = nil;
        [self.layer addSublayer:self.shapeLayer];
        self.imageLayer.mask = self.shapeLayer;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    //底图
    _image = image;
    self.imageLayer.contents = (id)image.CGImage;
}

// drawRect是内存杀手，后续解决这个问题
- (void)drawRect:(CGRect)rect {
    if (_isBlur) {
    
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        for (PJEditImageStroke *stroke in _stroks) {
            [stroke strokeWithContext:context];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_isBlur) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathMoveToPoint(self.blurPath, NULL, point.x, point.y);
        CGMutablePathRef path = CGPathCreateMutableCopy(self.blurPath);
        self.shapeLayer.path = path;
        CGPathRelease(path);
        self.appendPaths = [NSMutableArray array];
        [self.appendPaths addObject:[NSValue valueWithCGPoint:point]];
    } else {
        currentPath = CGPathCreateMutable();
        PJEditImageStroke *stroke = [[PJEditImageStroke alloc] init];
        stroke.path = currentPath;
        stroke.blendMode = _isEarse ? kCGBlendModeDestinationIn : kCGBlendModeNormal;
        stroke.strokeWidth = _isEarse ? 20.0 : _lineWidth;
        stroke.lineColor = _isEarse ? [UIColor clearColor] : _lineColor;
        [_stroks addObject:stroke];
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathMoveToPoint(currentPath, NULL, point.x, point.y);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_isBlur) {
        [super touchesMoved:touches withEvent:event];
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathAddLineToPoint(self.blurPath, NULL, point.x, point.y);
        CGMutablePathRef path = CGPathCreateMutableCopy(self.blurPath);
        self.shapeLayer.path = path;
        CGPathRelease(path);
        [self.appendPaths addObject:[NSValue valueWithCGPoint:point]];
    } else {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathAddLineToPoint(currentPath, NULL, point.x, point.y);
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_isBlur) {
        [self.allPaths addObject:self.appendPaths];
    }
}

//清除
- (void)clear{
    [self.allPaths removeAllObjects];
    self.blurPath = CGPathCreateMutable();
    CGPathMoveToPoint(self.blurPath, NULL, 0, 0);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.blurPath);
    self.shapeLayer.path = path;
    CGPathRelease(path);
}

//撤回
- (void)back{
    // 如果PM要求需要点击统一撤回画笔和马赛克，在此修改
    [self.allPaths removeLastObject];
    self.blurPath = CGPathCreateMutable();
    //如果撤回步骤大于0次执行撤回 否则执行清除操作
    if (self.allPaths.count>0) {
        for (int i=0; i<self.allPaths.count; i++) {
            NSArray * array = self.allPaths[i];
            for (int j =0 ; j<array.count; j++) {
                CGPoint point = [array[j] CGPointValue];
                if (j==0) {
                    CGPathMoveToPoint(self.blurPath, NULL, point.x, point.y);
                    CGMutablePathRef path = CGPathCreateMutableCopy(self.blurPath);
                    self.shapeLayer.path = path;
                    CGPathRelease(path);
                    
                }else{
                    CGPathAddLineToPoint(self.blurPath, NULL, point.x, point.y);
                    CGMutablePathRef path = CGPathCreateMutableCopy(self.blurPath);
                    self.shapeLayer.path = path;
                    CGPathRelease(path);
                }
            }
        }
    }else{
        [self clear];
    }
}

// 一键清屏
- (void)clearScreen {
    _isEarse = NO;
    [self clear];
    [_stroks removeAllObjects];
    [self setNeedsDisplay];
}

// 撤回
// 按照微信的来，画笔只能撤回画笔，马赛克只能撤回马赛克
- (void)revokeScreen {
    _isEarse = NO;
    if (_isBlur) {
        [self back];
    } else {
        [_stroks removeLastObject];
        [self setNeedsDisplay];
    }
}

// 橡皮擦
- (void)eraseSreen {
    self.isEarse = YES;
}

// 设置画笔颜色
- (void)setStrokeColor:(UIColor *)lineColor {
    _isEarse = NO;
    self.lineColor = lineColor;
}

// 因为不支持ARC，需要手动释放
- (void)dealloc {
    if (currentPath) {
        CGPathRelease(currentPath);
    }
    if (self.blurPath) {
        CGPathRelease(self.blurPath);
    }
}

@end
