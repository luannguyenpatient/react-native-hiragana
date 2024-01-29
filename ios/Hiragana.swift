import Foundation

@objc(Hiragana)
class Hiragana: NSObject {

  @objc(convert:withResolver:withRejecter:)
  func convert(str: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
      resolve(str.hiragana)
    }
}

enum Kana { case hiragana, katakana }

func convert(_ input: String, to kana: Kana) -> String {
    let inputsNewLine = input.components(separatedBy: "\n")
    var results: [String] = []
    inputsNewLine.forEach { str in
        results.append(kanjiToHiragana(str, to: kana))
    }
    return results.joined(separator: "\n")
}

extension NSMutableString {//
    func isFullWidth() -> Bool {
        let regex = #"^[ぁ-んァ-ン一-龥]"#
        guard let gRegex = try? NSRegularExpression(pattern: regex) else {
            return false
        }
        
        let range = NSRange(location: 0, length: (self as String).utf16.count)
        
        if gRegex.firstMatch(in: self as String, options: [], range: range) != nil {
            return true
        }
        
        return false
    }
    
    func isNumber() -> Bool {
        let characters = CharacterSet.decimalDigits
        return CharacterSet(charactersIn: self as String).isSubset(of: characters)
    }
}

extension String {
    var hiragana: String { convert(self, to: .hiragana) }
    
    
    
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
    
    func containKanji() -> Bool {
        for item in self {
            if "\(item)".isValidKanji() {
                return true
            }
        }
        return false
    }
    
    func tokenize() -> [String] {
        let inputRange = CFRangeMake(0, self.count)
        let flag = UInt(kCFStringTokenizerUnitWord)
        let locale = CFLocaleCopyCurrent()
        let tokenizer = CFStringTokenizerCreate( kCFAllocatorDefault, self as CFString, inputRange, flag, locale)
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var tokens : [String] = []
        
        while tokenType != CFStringTokenizerTokenType(rawValue: 0)
        {
            let currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let substring = self.substringWithRange(aRange: currentTokenRange)
            tokens.append(substring)
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return tokens
    }
    
    func substringWithRange(aRange : CFRange) -> String {
        let nsrange = NSMakeRange(aRange.location, aRange.length)
        let substring = (self as NSString).substring(with: nsrange)
        return substring
    }
}

private extension CFStringTokenizer {
    var hiragana: String { string(to: kCFStringTransformLatinHiragana) }
    var katakana: String { string(to: kCFStringTransformLatinKatakana) }

    private func string(to transform: CFString) -> String {
        var output: String = ""
        while !CFStringTokenizerAdvanceToNextToken(self).isEmpty {
            let letter = letter(to: transform)
            output.append(letter.isEmpty ? " " : letter)
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
        
        if !mutableString.isNumber() {
            CFStringTransform(mutableString, nil, kCFStringTransformFullwidthHalfwidth, true)
        }
        
        return mutableString as String
    }
}

func kanjiToHiragana(_ input: String, to kana: Kana) -> String {
    let trimmed: String = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let tokenizer: CFStringTokenizer =
        CFStringTokenizerCreate(kCFAllocatorDefault,
                                trimmed as CFString,
                                CFRangeMake(0, trimmed.utf16.count),
                                kCFStringTokenizerUnitWordBoundary,
                                Locale(identifier: "ja") as CFLocale)
    switch kana {
    case .hiragana: return tokenizer.hiragana
    case .katakana: return tokenizer.katakana
    }
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
