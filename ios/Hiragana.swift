@objc(Hiragana)
class Hiragana: NSObject {

  @objc(convert:withResolver:withRejecter:)
  func convert(str: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
      let inputText = str as NSString
      let outputText = NSMutableString()

      var range: CFRange = CFRangeMake(0, inputText.length)
      let locale: CFLocale = CFLocaleCopyCurrent()

      let tokenizer: CFStringTokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, inputText as CFString, range, kCFStringTokenizerUnitWordBoundary, locale)
      var tokenType: CFStringTokenizerTokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)

      while tokenType != CFStringTokenizerTokenType(rawValue: 0) {
          range = CFStringTokenizerGetCurrentTokenRange(tokenizer)

          let latin: CFTypeRef = CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription)
          let romaji = latin as! NSString

          let furigana: NSMutableString = romaji.mutableCopy() as! NSMutableString
          CFStringTransform(furigana as CFMutableString, nil, kCFStringTransformLatinHiragana, false)

          outputText.append(furigana as String)
          tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
      }

      resolve(outputText)
    }
  }
