#import "DocumentRichTextView.h"
#import <math.h>

static const CGFloat IPAD1_DOC_MARGIN=14.0f;
static const CGFloat IPAD1_DOC_PAGE_HEIGHT=900.0f;
static const CGFloat IPAD1_DOC_PAGE_GAP=8.0f;
static const NSInteger IPAD1_DOC_PAGE_RADIUS=2;

@interface IP1DOCXPageView : UIView {
    CTFramesetterRef _framesetter;
    CFRange _textRange;
}
- (id)initWithFrame:(CGRect)frame framesetter:(CTFramesetterRef)framesetter range:(CFRange)range;
@end

@implementation IP1DOCXPageView

- (id)initWithFrame:(CGRect)frame framesetter:(CTFramesetterRef)framesetter range:(CFRange)range {
    if((self=[super initWithFrame:frame])) {
        self.backgroundColor=[UIColor whiteColor];
        self.opaque=YES;
        _framesetter=framesetter;
        if(_framesetter) CFRetain(_framesetter);
        _textRange=range;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    (void)rect;
    CGContextRef context=UIGraphicsGetCurrentContext();
    if(!context || !_framesetter || _textRange.length<=0) return;

    CGRect textRect=CGRectInset(self.bounds,IPAD1_DOC_MARGIN,IPAD1_DOC_MARGIN);
    if(textRect.size.width<1.0f || textRect.size.height<1.0f) return;

    CGPathRef path=CGPathCreateWithRect(textRect,NULL);
    CTFrameRef frame=CTFramesetterCreateFrame(_framesetter,_textRange,path,NULL);
    CGPathRelease(path);
    if(!frame) return;

    CGContextSaveGState(context);
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0,self.bounds.size.height);
    CGContextScaleCTM(context,1.0f,-1.0f);
    CTFrameDraw(frame,context);
    CGContextRestoreGState(context);
    CFRelease(frame);
}

- (void)dealloc {
    if(_framesetter) CFRelease(_framesetter);
    [super dealloc];
}
@end

@implementation DocumentRichTextView
@synthesize plainText=_plainText;

- (id)initWithFrame:(CGRect)frame {
    if((self=[super initWithFrame:frame])) {
        self.backgroundColor=[UIColor clearColor];
        self.opaque=NO;
        self.clipsToBounds=NO;
        _baseFontSize=17.0f;
        _pageRanges=[[NSMutableArray alloc] init];
        _visiblePages=[[NSMutableDictionary alloc] init];
        _layoutWidth=0.0f;
        _contentHeight=1.0f;
    }
    return self;
}

- (CGFloat)baseFontSize { return _baseFontSize; }

- (void)clearVisiblePages {
    for(NSNumber *key in [_visiblePages allKeys]) {
        UIView *view=[_visiblePages objectForKey:key];
        [view removeFromSuperview];
    }
    [_visiblePages removeAllObjects];
}

- (void)clearLayout {
    [self clearVisiblePages];
    [_pageRanges removeAllObjects];
    _layoutWidth=0.0f;
    _contentHeight=1.0f;
}

- (void)setBaseFontSize:(CGFloat)size {
    if(size<10.0f) size=10.0f;
    if(size>28.0f) size=28.0f;
    if(fabs(_baseFontSize-size)<0.01f) return;
    _baseFontSize=size;
    [self rebuildFramesetter];
}

- (void)applyFontNamed:(CFStringRef)name size:(CGFloat)size to:(CFMutableAttributedStringRef)attr range:(CFRange)range {
    if(range.length<=0) return;
    CTFontRef font=CTFontCreateWithName(name,size,NULL);
    if(font) {
        CFAttributedStringSetAttribute(attr,range,kCTFontAttributeName,font);
        CFRelease(font);
    }
}

- (void)rebuildFramesetter {
    [self clearLayout];
    if(_framesetter) { CFRelease(_framesetter); _framesetter=NULL; }
    if(!_plainText) return;

    CFMutableAttributedStringRef attr=CFAttributedStringCreateMutable(kCFAllocatorDefault,0);
    CFAttributedStringReplaceString(attr,CFRangeMake(0,0),(CFStringRef)_plainText);
    CFRange all=CFRangeMake(0,[_plainText length]);
    [self applyFontNamed:CFSTR("Helvetica") size:_baseFontSize to:attr range:all];

    CGFloat lineSpacing=3.0f;
    CGFloat paragraphSpacing=7.0f;
    CTParagraphStyleSetting settings[2]={
        { kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpacing },
        { kCTParagraphStyleSpecifierParagraphSpacing,sizeof(CGFloat),&paragraphSpacing }
    };
    CTParagraphStyleRef paragraph=CTParagraphStyleCreate(settings,2);
    if(paragraph) {
        CFAttributedStringSetAttribute(attr,all,kCTParagraphStyleAttributeName,paragraph);
        CFRelease(paragraph);
    }

    for(NSDictionary *style in _styles) {
        NSUInteger location=[[style objectForKey:@"location"] unsignedIntegerValue];
        NSUInteger length=[[style objectForKey:@"length"] unsignedIntegerValue];
        if(location>[_plainText length] || length>[_plainText length]-location) continue;
        CFRange r=CFRangeMake(location,length);
        NSString *type=[style objectForKey:@"type"];
        if([type isEqualToString:@"bold"]) {
            [self applyFontNamed:CFSTR("Helvetica-Bold") size:_baseFontSize to:attr range:r];
        } else if([type isEqualToString:@"italic"]) {
            [self applyFontNamed:CFSTR("Helvetica-Oblique") size:_baseFontSize to:attr range:r];
        } else if([type isEqualToString:@"heading"]) {
            NSUInteger level=[[style objectForKey:@"level"] unsignedIntegerValue];
            CGFloat extra=(level<=1)?8.0f:(level==2)?6.0f:(level==3)?4.0f:2.0f;
            [self applyFontNamed:CFSTR("Helvetica-Bold") size:MIN(32.0f,_baseFontSize+extra) to:attr range:r];
        }
    }

    _framesetter=CTFramesetterCreateWithAttributedString(attr);
    CFRelease(attr);
}

- (void)setDocumentText:(NSString *)text styles:(NSArray *)styles {
    [_plainText release];
    _plainText=[text copy];
    [_styles release];
    _styles=[styles copy];
    [self rebuildFramesetter];
}

- (void)buildPageRangesForWidth:(CGFloat)width {
    if(!_framesetter || ![_plainText length] || width<=32.0f) {
        [self clearLayout];
        _layoutWidth=width;
        _contentHeight=1.0f;
        return;
    }

    if(fabs(_layoutWidth-width)<0.5f && [_pageRanges count]>0) return;

    [self clearLayout];
    _layoutWidth=width;

    CGFloat textWidth=MAX(1.0f,width-(IPAD1_DOC_MARGIN*2.0f));
    CGFloat textHeight=MAX(1.0f,IPAD1_DOC_PAGE_HEIGHT-(IPAD1_DOC_MARGIN*2.0f));
    NSUInteger location=0;
    NSUInteger textLength=[_plainText length];

    while(location<textLength) {
        CGPathRef path=CGPathCreateWithRect(CGRectMake(IPAD1_DOC_MARGIN,IPAD1_DOC_MARGIN,textWidth,textHeight),NULL);
        CTFrameRef frame=CTFramesetterCreateFrame(_framesetter,CFRangeMake((CFIndex)location,0),path,NULL);
        CGPathRelease(path);
        if(!frame) break;

        CFRange visible=CTFrameGetVisibleStringRange(frame);
        CFRelease(frame);
        if(visible.length<=0) break;

        NSUInteger pageLength=(NSUInteger)visible.length;
        if(location+pageLength>textLength) pageLength=textLength-location;
        [_pageRanges addObject:[NSValue valueWithRange:NSMakeRange(location,pageLength)]];
        location+=pageLength;
    }

    NSUInteger pageCount=[_pageRanges count];
    if(pageCount>0) {
        _contentHeight=(CGFloat)pageCount*IPAD1_DOC_PAGE_HEIGHT+(CGFloat)(pageCount-1)*IPAD1_DOC_PAGE_GAP;
    } else {
        _contentHeight=1.0f;
    }
}

- (CGFloat)contentHeightForWidth:(CGFloat)width {
    [self buildPageRangesForWidth:width];
    return _contentHeight;
}

- (void)updateVisiblePagesForOffset:(CGFloat)offset viewportHeight:(CGFloat)viewportHeight {
    NSUInteger pageCount=[_pageRanges count];
    if(pageCount==0 || _layoutWidth<=32.0f) {
        [self clearVisiblePages];
        return;
    }

    CGFloat stride=IPAD1_DOC_PAGE_HEIGHT+IPAD1_DOC_PAGE_GAP;
    NSInteger first=(NSInteger)floor(MAX(0.0f,offset)/stride)-IPAD1_DOC_PAGE_RADIUS;
    NSInteger last=(NSInteger)floor(MAX(0.0f,offset+MAX(1.0f,viewportHeight))/stride)+IPAD1_DOC_PAGE_RADIUS;
    if(first<0) first=0;
    if(last>=(NSInteger)pageCount) last=(NSInteger)pageCount-1;

    for(NSNumber *key in [[_visiblePages allKeys] copy]) {
        NSInteger idx=[key integerValue];
        if(idx<first || idx>last) {
            UIView *view=[_visiblePages objectForKey:key];
            [view removeFromSuperview];
            [_visiblePages removeObjectForKey:key];
        }
    }

    for(NSInteger idx=first; idx<=last; idx++) {
        NSNumber *key=[NSNumber numberWithInteger:idx];
        if([_visiblePages objectForKey:key]) continue;

        NSRange r=[[_pageRanges objectAtIndex:(NSUInteger)idx] rangeValue];
        CGFloat y=(CGFloat)idx*stride;
        IP1DOCXPageView *page=[[[IP1DOCXPageView alloc] initWithFrame:CGRectMake(0,y,_layoutWidth,IPAD1_DOC_PAGE_HEIGHT)
                                                                  framesetter:_framesetter
                                                                        range:CFRangeMake((CFIndex)r.location,(CFIndex)r.length)] autorelease];
        [self addSubview:page];
        [_visiblePages setObject:page forKey:key];
    }
}

- (CGFloat)yOffsetForCharacterIndex:(NSUInteger)index {
    NSUInteger count=[_pageRanges count];
    CGFloat stride=IPAD1_DOC_PAGE_HEIGHT+IPAD1_DOC_PAGE_GAP;
    for(NSUInteger i=0;i<count;i++) {
        NSRange r=[[_pageRanges objectAtIndex:i] rangeValue];
        if(index>=r.location && index<NSMaxRange(r)) {
            return MAX(0.0f,(CGFloat)i*stride-IPAD1_DOC_MARGIN);
        }
    }
    return 0.0f;
}

- (void)dealloc {
    [self clearLayout];
    if(_framesetter) CFRelease(_framesetter);
    [_plainText release];
    [_styles release];
    [_pageRanges release];
    [_visiblePages release];
    [super dealloc];
}
@end
