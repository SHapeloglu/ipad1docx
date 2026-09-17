#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface DocumentRichTextView : UIView {
    NSString *_plainText;
    NSArray *_styles;
    CGFloat _baseFontSize;
    CTFramesetterRef _framesetter;
    NSMutableArray *_pageRanges;
    NSMutableDictionary *_visiblePages;
    CGFloat _layoutWidth;
    CGFloat _contentHeight;
}
@property(nonatomic,readonly) NSString *plainText;
@property(nonatomic,assign) CGFloat baseFontSize;
- (void)setDocumentText:(NSString *)text styles:(NSArray *)styles;
- (CGFloat)contentHeightForWidth:(CGFloat)width;
- (void)updateVisiblePagesForOffset:(CGFloat)offset viewportHeight:(CGFloat)viewportHeight;
- (CGFloat)yOffsetForCharacterIndex:(NSUInteger)index;
@end
