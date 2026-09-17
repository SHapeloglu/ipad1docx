#import "DOCXReader.h"
#import <zlib.h>

static const unsigned long long IPAD1_DOCX_MAX_COMPRESSED = 8ULL * 1024ULL * 1024ULL;
static const NSUInteger IPAD1_DOCX_MAX_XML = 4U * 1024U * 1024U;
static const NSUInteger IPAD1_DOCX_MAX_STYLES = 4096U;
static NSString * const IPAD1_DOCX_DEBUG_LOG=@"/var/mobile/Media/iPad1Files/ipad1docx-debug.log";

static void IP1DOCXLog(NSString *message) {
    if(!message) return;
    NSString *line=[message stringByAppendingString:@"\n"];
    NSData *data=[line dataUsingEncoding:NSUTF8StringEncoding];
    NSFileHandle *handle=[NSFileHandle fileHandleForWritingAtPath:IPAD1_DOCX_DEBUG_LOG];
    if(!handle) {
        [data writeToFile:IPAD1_DOCX_DEBUG_LOG atomically:YES];
        return;
    }
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
}

static uint16_t IP1LE16(const unsigned char *p) { return (uint16_t)(p[0] | (p[1] << 8)); }
static uint32_t IP1LE32(const unsigned char *p) { return (uint32_t)(p[0] | (p[1] << 8) | (p[2] << 16) | (p[3] << 24)); }

static BOOL IP1DOCXHasVisibleText(NSString *text) {
    if(![text length]) return NO;
    NSMutableCharacterSet *set=[[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];
    [set addCharactersInString:@"\u00A0"];
    return [[text stringByTrimmingCharactersInSet:set] length]>0;
}

static NSError *IP1DOCXError(NSInteger code, NSString *message) {
    return [NSError errorWithDomain:@"iPad1DOCXReader.DOCX" code:code userInfo:[NSDictionary dictionaryWithObject:(message?:@"DOCX okunamadı") forKey:NSLocalizedDescriptionKey]];
}

static NSData *IP1DOCXInflateRaw(const unsigned char *bytes, NSUInteger compressedSize, NSUInteger uncompressedSize) {
    IP1DOCXLog([NSString stringWithFormat:@"DOCX inflate begin: compressed=%u uncompressed=%u",(unsigned int)compressedSize,(unsigned int)uncompressedSize]);
    if(uncompressedSize==0) return [NSData data];
    if(uncompressedSize>IPAD1_DOCX_MAX_XML) return nil;
    NSMutableData *out=[NSMutableData dataWithLength:uncompressedSize];
    z_stream stream;
    memset(&stream,0,sizeof(stream));
    stream.next_in=(Bytef *)bytes;
    stream.avail_in=(uInt)compressedSize;
    stream.next_out=(Bytef *)[out mutableBytes];
    stream.avail_out=(uInt)uncompressedSize;
    int initRC=inflateInit2(&stream,-MAX_WBITS);
    IP1DOCXLog([NSString stringWithFormat:@"DOCX inflateInit2 rc=%d",initRC]);
    if(initRC!=Z_OK) return nil;
    int rc=inflate(&stream,Z_FINISH);
    IP1DOCXLog([NSString stringWithFormat:@"DOCX inflate rc=%d total_out=%lu",rc,(unsigned long)stream.total_out]);
    inflateEnd(&stream);
    if(rc!=Z_STREAM_END) return nil;
    [out setLength:stream.total_out];
    IP1DOCXLog(@"DOCX inflate success");
    return out;
}

static NSData *IP1DOCXDocumentXMLAtPath(NSString *path, NSError **error) {
    IP1DOCXLog([NSString stringWithFormat:@"DOCX ZIP begin: %@",path]);
    NSDictionary *attrs=[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    unsigned long long fileSize=[[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    IP1DOCXLog([NSString stringWithFormat:@"DOCX ZIP file size=%llu",fileSize]);
    if(fileSize==0 || fileSize>IPAD1_DOCX_MAX_COMPRESSED) {
        if(error) *error=IP1DOCXError(1,@"DOCX dosyası iPad 1 için güvenli 8 MiB sınırını aşıyor veya boş.");
        return nil;
    }
    NSData *zip=[NSData dataWithContentsOfFile:path];
    if(!zip) { if(error) *error=IP1DOCXError(2,@"DOCX paketi okunamadı."); return nil; }
    IP1DOCXLog([NSString stringWithFormat:@"DOCX ZIP loaded bytes=%u",(unsigned int)[zip length]]);
    const unsigned char *b=(const unsigned char *)[zip bytes];
    NSUInteger n=[zip length];
    if(n<22) { if(error) *error=IP1DOCXError(3,@"Geçersiz DOCX/ZIP paketi."); return nil; }

    NSUInteger minPos=(n>65557)?(n-65557):0;
    NSInteger eocd=-1;
    for(NSInteger i=(NSInteger)n-22;i>=(NSInteger)minPos;i--) {
        if(IP1LE32(b+i)==0x06054b50U) { eocd=i; break; }
    }
    IP1DOCXLog([NSString stringWithFormat:@"DOCX EOCD=%ld",(long)eocd]);
    if(eocd<0) { if(error) *error=IP1DOCXError(4,@"DOCX ZIP son kaydı bulunamadı."); return nil; }
    const unsigned char *e=b+eocd;
    uint16_t entries=IP1LE16(e+10);
    uint32_t cdSize=IP1LE32(e+12);
    uint32_t cdOffset=IP1LE32(e+16);
    IP1DOCXLog([NSString stringWithFormat:@"DOCX central dir entries=%u size=%u offset=%u",entries,cdSize,cdOffset]);
    if((uint64_t)cdOffset+cdSize>n) { if(error) *error=IP1DOCXError(5,@"DOCX merkez dizini geçersiz."); return nil; }

    NSUInteger pos=cdOffset;
    for(uint16_t idx=0; idx<entries && pos+46<=n; idx++) {
        if(IP1LE32(b+pos)!=0x02014b50U) break;
        uint16_t flags=IP1LE16(b+pos+8);
        uint16_t method=IP1LE16(b+pos+10);
        uint32_t compressedSize=IP1LE32(b+pos+20);
        uint32_t uncompressedSize=IP1LE32(b+pos+24);
        uint16_t nameLen=IP1LE16(b+pos+28);
        uint16_t extraLen=IP1LE16(b+pos+30);
        uint16_t commentLen=IP1LE16(b+pos+32);
        uint32_t localOffset=IP1LE32(b+pos+42);
        NSUInteger next=pos+46+(NSUInteger)nameLen+extraLen+commentLen;
        if(next>n) break;
        NSString *name=[[[NSString alloc] initWithBytes:b+pos+46 length:nameLen encoding:NSUTF8StringEncoding] autorelease];
        if([name isEqualToString:@"word/document.xml"]) {
            IP1DOCXLog([NSString stringWithFormat:@"DOCX document.xml found: method=%u flags=%u compressed=%u uncompressed=%u localOffset=%u",method,flags,compressedSize,uncompressedSize,localOffset]);
            if(flags & 1) { if(error) *error=IP1DOCXError(6,@"Şifreli DOCX desteklenmiyor."); return nil; }
            if(uncompressedSize>IPAD1_DOCX_MAX_XML) { if(error) *error=IP1DOCXError(7,@"DOCX ana XML içeriği 4 MiB güvenli sınırını aşıyor."); return nil; }
            if((uint64_t)localOffset+30>n || IP1LE32(b+localOffset)!=0x04034b50U) { if(error) *error=IP1DOCXError(8,@"DOCX ana XML yerel kaydı geçersiz."); return nil; }
            uint16_t localNameLen=IP1LE16(b+localOffset+26);
            uint16_t localExtraLen=IP1LE16(b+localOffset+28);
            NSUInteger dataOffset=(NSUInteger)localOffset+30+localNameLen+localExtraLen;
            IP1DOCXLog([NSString stringWithFormat:@"DOCX data offset=%u",(unsigned int)dataOffset]);
            if((uint64_t)dataOffset+compressedSize>n) { if(error) *error=IP1DOCXError(9,@"DOCX ana XML verisi eksik."); return nil; }
            if(method==0) {
                IP1DOCXLog(@"DOCX document.xml stored, returning raw data");
                return [NSData dataWithBytes:b+dataOffset length:compressedSize];
            }
            if(method==8) {
                NSData *xml=IP1DOCXInflateRaw(b+dataOffset,compressedSize,uncompressedSize);
                if(!xml && error) *error=IP1DOCXError(10,@"DOCX ana XML verisi açılamadı.");
                IP1DOCXLog([NSString stringWithFormat:@"DOCX inflate returned bytes=%u",(unsigned int)[xml length]]);
                return xml;
            }
            if(error) *error=IP1DOCXError(11,@"DOCX içinde desteklenmeyen sıkıştırma yöntemi var.");
            return nil;
        }
        pos=next;
    }
    IP1DOCXLog(@"DOCX word/document.xml not found");
    if(error) *error=IP1DOCXError(12,@"word/document.xml bulunamadı.");
    return nil;
}

@implementation DOCXReader
@synthesize plainText=_plainText;
@synthesize styles=_styles;

+ (unsigned long long)maximumSafeCompressedSize { return IPAD1_DOCX_MAX_COMPRESSED; }
+ (NSUInteger)maximumSafeXMLSize { return IPAD1_DOCX_MAX_XML; }

- (void)addStyle:(NSString *)type location:(NSUInteger)location length:(NSUInteger)length level:(NSUInteger)level {
    if(!type || length==0 || [_workingStyles count]>=IPAD1_DOCX_MAX_STYLES) return;
    [_workingStyles addObject:[NSDictionary dictionaryWithObjectsAndKeys:type,@"type",[NSNumber numberWithUnsignedInteger:location],@"location",[NSNumber numberWithUnsignedInteger:length],@"length",[NSNumber numberWithUnsignedInteger:level],@"level",nil]];
}

- (void)appendText:(NSString *)text {
    if(![text length]) return;
    if(_inTable && _inCell && !IP1DOCXHasVisibleText(text)) return;
    if(_paragraphIsList && !_paragraphHasText) [_workingText appendString:@"• "];
    NSUInteger start=[_workingText length];
    [_workingText appendString:text];
    NSUInteger len=[_workingText length]-start;
    if(_runBold) [self addStyle:@"bold" location:start length:len level:0];
    if(_runItalic) [self addStyle:@"italic" location:start length:len level:0];
    if(_headingLevel>0) [self addStyle:@"heading" location:start length:len level:_headingLevel];
    _paragraphHasText=YES;
}

- (BOOL)loadDOCXAtPath:(NSString *)path error:(NSError **)error {
    IP1DOCXLog(@"DOCX loadDOCXAtPath begin");
    [_plainText release]; _plainText=nil;
    [_styles release]; _styles=nil;
    NSData *xml=IP1DOCXDocumentXMLAtPath(path,error);
    if(!xml) {
        IP1DOCXLog([NSString stringWithFormat:@"DOCX XML extraction failed: %@",(error && *error)?[*error localizedDescription]:@"unknown"]);
        return NO;
    }
    IP1DOCXLog([NSString stringWithFormat:@"DOCX XML ready bytes=%u",(unsigned int)[xml length]]);
    _workingText=[[NSMutableString alloc] initWithCapacity:MIN((NSUInteger)262144,[xml length])];
    _workingStyles=[[NSMutableArray alloc] init];
    _textBuffer=[[NSMutableString alloc] init];
    IP1DOCXLog(@"DOCX parser create");
    NSXMLParser *parser=[[[NSXMLParser alloc] initWithData:xml] autorelease];
    IP1DOCXLog(@"DOCX parser created");
    parser.delegate=self;
    parser.shouldProcessNamespaces=NO;
    parser.shouldReportNamespacePrefixes=NO;
    IP1DOCXLog(@"DOCX parser parse begin");
    BOOL ok=[parser parse];
    IP1DOCXLog([NSString stringWithFormat:@"DOCX parser parse end ok=%@",ok?@"YES":@"NO"]);
    if(!ok && error) *error=parser.parserError?:IP1DOCXError(13,@"DOCX XML ayrıştırılamadı.");
    if(ok) {
        IP1DOCXLog([NSString stringWithFormat:@"DOCX parser output text=%u styles=%u",(unsigned int)[_workingText length],(unsigned int)[_workingStyles count]]);
        _plainText=[_workingText copy];
        _styles=[_workingStyles copy];
        IP1DOCXLog(@"DOCX result copied");
    }
    [_workingText release]; _workingText=nil;
    [_workingStyles release]; _workingStyles=nil;
    [_textBuffer release]; _textBuffer=nil;
    IP1DOCXLog(@"DOCX loadDOCXAtPath end");
    return ok;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    (void)parser; (void)namespaceURI; (void)qName;
    NSString *name=[elementName hasPrefix:@"w:"]?[elementName substringFromIndex:2]:elementName;
    if([name isEqualToString:@"p"]) { _paragraphHasText=NO; _paragraphIsList=NO; _headingLevel=0; }
    else if([name isEqualToString:@"r"]) { _runBold=NO; _runItalic=NO; }
    else if([name isEqualToString:@"b"]) _runBold=YES;
    else if([name isEqualToString:@"i"]) _runItalic=YES;
    else if([name isEqualToString:@"numPr"]) _paragraphIsList=YES;
    else if([name isEqualToString:@"pStyle"]) {
        NSString *v=[attributeDict objectForKey:@"w:val"]?:[attributeDict objectForKey:@"val"];
        NSString *lower=[v lowercaseString];
        BOOL heading=([lower rangeOfString:@"heading"].location!=NSNotFound ||
                      [lower rangeOfString:@"başlık"].location!=NSNotFound ||
                      [lower rangeOfString:@"baslik"].location!=NSNotFound ||
                      [lower rangeOfString:@"balik"].location!=NSNotFound);
        BOOL title=([lower isEqualToString:@"title"] || [lower hasSuffix:@"title"]);
        BOOL subtitle=([lower isEqualToString:@"subtitle"] || [lower rangeOfString:@"subtitle"].location!=NSNotFound);
        if(heading || title || subtitle) {
            NSInteger level=title?1:(subtitle?2:1);
            NSScanner *scanner=[NSScanner scannerWithString:lower];
            [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:NULL];
            NSInteger scanned=0;
            if([scanner scanInteger:&scanned] && scanned>0) level=scanned;
            _headingLevel=(NSUInteger)MAX(1,MIN(6,level));
        }
    }
    else if([name isEqualToString:@"t"]) { _inText=YES; [_textBuffer setString:@""]; }
    else if([name isEqualToString:@"tab"]) [self appendText:@"\t"];
    else if([name isEqualToString:@"br"]) [self appendText:@"\n"];
    else if([name isEqualToString:@"tbl"]) _inTable=YES;
    else if([name isEqualToString:@"tc"]) { _inCell=YES; _cellStartLength=[_workingText length]; }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    (void)parser;
    if(_inText) [_textBuffer appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    (void)parser; (void)namespaceURI; (void)qName;
    NSString *name=[elementName hasPrefix:@"w:"]?[elementName substringFromIndex:2]:elementName;
    if([name isEqualToString:@"t"]) { _inText=NO; [self appendText:_textBuffer]; [_textBuffer setString:@""]; }
    else if([name isEqualToString:@"p"]) {
        if(_inTable && _inCell) {
            if(_paragraphHasText && [_workingText length] && ![_workingText hasSuffix:@" "] && ![_workingText hasSuffix:@"\n"] && ![_workingText hasSuffix:@"  │  "]) {
                [_workingText appendString:@" "];
            }
        } else {
            if([_workingText length] && ![_workingText hasSuffix:@"\n"]) [_workingText appendString:@"\n"];
            if(_headingLevel>0) [_workingText appendString:@"\n"];
        }
        _paragraphHasText=NO; _paragraphIsList=NO; _headingLevel=0;
    }
    else if([name isEqualToString:@"tc"]) {
        if(_inTable && [_workingText length]>_cellStartLength) {
            while([_workingText length]>_cellStartLength && [_workingText hasSuffix:@" "]) {
                [_workingText deleteCharactersInRange:NSMakeRange([_workingText length]-1,1)];
            }
            if([_workingText length]>_cellStartLength && ![_workingText hasSuffix:@"\n"] && ![_workingText hasSuffix:@"  │  "]) {
                [_workingText appendString:@"  │  "];
            }
        }
        _inCell=NO;
    }
    else if([name isEqualToString:@"tr"]) {
        if(_inTable && [_workingText hasSuffix:@"  │  "]) [_workingText deleteCharactersInRange:NSMakeRange([_workingText length]-5,5)];
        if(_inTable && [_workingText length] && ![_workingText hasSuffix:@"\n"]) [_workingText appendString:@"\n"];
    }
    else if([name isEqualToString:@"tbl"]) {
        _inTable=NO;
        if([_workingText length] && ![_workingText hasSuffix:@"\n\n"]) [_workingText appendString:@"\n"];
    }
}

- (void)dealloc {
    [_plainText release]; [_styles release]; [_workingText release]; [_workingStyles release]; [_textBuffer release];
    [super dealloc];
}
@end
