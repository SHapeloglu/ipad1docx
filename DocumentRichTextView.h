#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface DocumentRichTextView : UIView {
    NSString *_plainText;
    NSArray *_styles;
    CGFloat _baseFontSize;
    CTFramesetterRef _framesetter;
}
@property(nonatomic,readonly) NSString *plainText;
@property(nonatomic,assign) CGFloat baseFontSize;
- (void)setDocumentText:(NSString *)text styles:(NSArray *)styles;
- (CGFloat)contentHeightForWidth:(CGFloat)width;
- (CGFloat)yOffsetForCharacterIndex:(NSUInteger)index;
@end
