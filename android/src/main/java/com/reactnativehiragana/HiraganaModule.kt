package com.reactnativehiragana
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.atilika.kuromoji.ipadic.Token
import com.atilika.kuromoji.ipadic.Tokenizer
import com.mariten.kanatools.KanaConverter

class HiraganaModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "Hiragana"
    }

    // Example method
    // See https://reactnative.dev/docs/native-modules-android
    @ReactMethod
    fun convert(str: String, promise: Promise) {
      promise.resolve(tranlateHiragana(str))
    }

    internal class Katakana(var katakana: String, var originally: Boolean)

    fun isKanji(str: String): Boolean {
      val pattern = "^[一-龠]*$".toRegex()
      return pattern.matches(str)
    }

    fun tranlateHiragana(str: String?): String {
      var z: Boolean
      val tokenizer = Tokenizer()
      val list: List<Token> = tokenizer.tokenize(str)
      val arrayList: ArrayList<Katakana> = ArrayList<Katakana>()
      for (next in list) {
        var surface = next.surface
        val reading = next.reading
        if (surface.matches(".*[\\u30A0-\\u30FF]+$".toRegex()) || surface.matches(".*[\\uFF10-\\uFF19]+$".toRegex())) {
          z = true
        } else {
          if (reading != "*") {
            if (isKanji(surface)) {
              surface = KanaConverter.convertKana(reading, KanaConverter.OP_ZEN_KATA_TO_ZEN_HIRA)
            }
          }
          z = false
        }
        arrayList.add(Katakana(surface, z))
      }
      var result = ""
      for (katakana in arrayList) {
        result += katakana.katakana
      }
      return result
    }
}
