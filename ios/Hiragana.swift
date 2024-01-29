import Foundation

@objc(Hiragana)
class Hiragana: NSObject {

  @objc(convert:withResolver:withRejecter:)
  func convert(str: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
      resolve(str.hiragana)
    }
}

private extension CFStringTokenizer {
    var hiragana: String { string(to: kCFStringTransformLatinHiragana) }
    var katakana: String { string(to: kCFStringTransformLatinKatakana) }

    private func string(to transform: CFString) -> String {
        var output: String = ""
        while !CFStringTokenizerAdvanceToNextToken(self).isEmpty {
            output.append(letter(to: transform))
        }
        return output
    }

    private func letter(to transform: CFString) -> String {
        let mutableString: NSMutableString =
            CFStringTokenizerCopyCurrentTokenAttribute(self, kCFStringTokenizerAttributeLatinTranscription)
                .flatMap { $0 as? NSString }
                .map { $0.mutableCopy() }
                .flatMap { $0 as? NSMutableString } ?? NSMutableString()
        CFStringTransform(mutableString, nil, transform, false)
        let string = mutableString as String
        return string.count == 0 ? " " : string
    }
}

enum Kana { case hiragana, katakana }

func convert(_ input: String, to kana: Kana) -> String {
    let trimmed: String = input.trimmingCharacters(in: .whitespacesAndNewlines)
    var array: [String] = []
    var strChar = ""
    trimmed.forEach { item in
        if strChar.count > 0 {
            let trimStr = "\(item)".trimmingCharacters(in: .whitespacesAndNewlines)
            if ("\(trimStr)".isValidKanji() && strChar.isValidKanji()) || (!"\(trimStr)".isValidKanji() && !strChar.isValidKanji()) || trimStr.count == 0 {
                strChar.append(item)
            } else  {
                array.append(strChar)
                strChar = "\(item)"
            }
        } else {
            strChar.append(item)
        }
    }
    if strChar.count > 0 {
        array.append(strChar)
    }
    
    // convert only string kanji
    var result = ""
    array.forEach { str in
        if str.isValidKanji() {
            let tokenizer: CFStringTokenizer =
                CFStringTokenizerCreate(kCFAllocatorDefault,
                                        str as CFString,
                                        CFRangeMake(0, str.utf16.count),
                                        kCFStringTokenizerUnitWordBoundary,
                                        Locale(identifier: "ja") as CFLocale)
            switch kana {
            case .hiragana: result.append(tokenizer.hiragana)
            case .katakana: result.append(tokenizer.katakana)
            }
        } else {
            result.append(str)
        }
    }
    return result
}

extension String {
    var hiragana: String { convert(self, to: .hiragana) }
    var katakana: String { convert(self, to: .katakana) }
    
    func isValidKanji() -> Bool {
        let regex = #"^[一-龠]*$"#
        guard let gRegex = try? NSRegularExpression(pattern: regex) else {
            return false
        }
        
        let range = NSRange(location: 0, length: self.utf16.count)
        
        if gRegex.firstMatch(in: self, options: [], range: range) != nil {
            return true
        }
        
        return false
    }
}
