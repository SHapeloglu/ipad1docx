#import "DocumentRichTextView.h"
#import <math.h>

static const CGFloat IPAD1_DOC_MARGIN=14.0f;

@implementation DocumentRichTextView
@synthesize plainText=_plainText;

- (id)initWithFrame:(CGRect)frame {
    if((self=[super initWithFrame:frame])) {
        self.backgroundColor=[UIColor whiteColor];
        self.opaque=YES;
        _baseFontSize=17.0f;
    }
    return self;
}

- (CGFloat)baseFontSize { return _baseFontSize; }

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
    if(_framesetter) { CFRelease(_framesetter); _framesetter=NULL; }
    if(!_plainText) { [self setNeedsDisplay]; return; }

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
    [self setNeedsDisplay];
}

- (void)setDocumentText:(NSString *)text styles:(NSArray *)styles {
    [_plainText release];
    _plainText=[text copy];
    [_styles release];
    _styles=[styles copy];
    [self rebuildFramesetter];
}

- (CGFloat)contentHeightForWidth:(CGFloat)width {
    if(!_framesetter) return 1.0f;
    CGFloat textWidth=MAX(1.0f,width-(IPAD1_DOC_MARGIN*2.0f));
    CGSize suggested=CTFramesetterSuggestFrameSizeWithConstraints(_framesetter,CFRangeMake(0,0),NULL,CGSizeMake(textWidth,CGFLOAT_MAX),NULL);
    return ceil(suggested.height)+(IPAD1_DOC_MARGIN*2.0f)+8.0f;
}

- (CTFrameRef)newFrameForCurrentBounds {
    if(!_framesetter) return NULL;
    CGRect rect=CGRectInset(self.bounds,IPAD1_DOC_MARGIN,IPAD1_DOC_MARGIN);
    if(rect.size.width<1.0f || rect.size.height<1.0f) return NULL;
    CGPathRef path=CGPathCreateWithRect(rect,NULL);
    CTFrameRef frame=CTFramesetterCreateFrame(_framesetter,CFRangeMake(0,0),path,NULL);
    CGPathRelease(path);
    return frame;
}

- (CGFloat)yOffsetForCharacterIndex:(NSUInteger)index {
    CTFrameRef frame=[self newFrameForCurrentBounds];
    if(!frame) return 0.0f;
    CFArrayRef lines=CTFrameGetLines(frame);
    CFIndex count=CFArrayGetCount(lines);
    CGPoint *origins=NULL;
    if(count>0) origins=(CGPoint *)calloc((size_t)count,sizeof(CGPoint));
    if(origins) CTFrameGetLineOrigins(frame,CFRangeMake(0,count),origins);
    CGFloat y=0.0f;
    for(CFIndex i=0;i<count;i++) {
        CTLineRef line=(CTLineRef)CFArrayGetValueAtIndex(lines,i);
        CFRange r=CTLineGetStringRange(line);
        if(index>=(NSUInteger)r.location && index<=(NSUInteger)(r.location+r.length)) {
            y=MAX(0.0f,self.bounds.size.height-origins[i].y-(_baseFontSize*2.0f));
            break;
        }
    }
    if(origins) free(origins);
    CFRelease(frame);
    return y;
}

- (void)drawRect:(CGRect)rect {
    (void)rect;
    CGContextRef context=UIGraphicsGetCurrentContext();
    if(!context || !_framesetter) return;
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0,self.bounds.size.height);
    CGContextScaleCTM(context,1.0f,-1.0f);
    CTFrameRef frame=[self newFrameForCurrentBounds];
    if(frame) {
        CTFrameDraw(frame,context);
        CFRelease(frame);
    }
    CGContextRestoreGState(context);
}

- (void)dealloc {
    if(_framesetter) CFRelease(_framesetter);
    [_plainText release];
    [_styles release];
    [super dealloc];
}
@end
