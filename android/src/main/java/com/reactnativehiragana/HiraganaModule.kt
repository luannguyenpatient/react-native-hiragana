package com.reactnativehiragana
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.atilika.kuromoji.ipadic.Token
import com.atilika.kuromoji.ipadic.Tokenizer
import com.mariten.kanatools.KanaConverter
import kotlinx.coroutines.*

class HiraganaModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  @OptIn(ExperimentalCoroutinesApi::class)
  private val coroutineScope = CoroutineScope(Dispatchers.IO.limitedParallelism(5))

    override fun getName(): String {
        return "Hiragana"
    }

    // Example method
    // See https://reactnative.dev/docs/native-modules-android
    @ReactMethod
    fun convert(str: String, promise: Promise) {
      coroutineScope.launch {
        withContext(coroutineScope.coroutineContext) {
          promise.resolve(tranlateHiragana(str))
        }
      }
    }

    private fun isKanji(str: String): Boolean {
      val pattern = "^[一-龠]*$".toRegex()
      return pattern.matches(str)
    }

    private fun containKanji(str: String): Boolean {
      str.forEach { char ->
        if (isKanji(char.toString())) {
          return true
        }
      }
      return false
    }

    private fun tranlateHiragana(str: String): String {
      var z: Boolean
      val tokenizer = Tokenizer()
      val list: List<Token> = tokenizer.tokenize(str)
      var result = ""

      for (next in list) {
        var surface = next.surface
        val reading = next.reading
        if (surface.matches(".*[\\u30A0-\\u30FF]+$".toRegex()) || surface.matches(".*[\\uFF10-\\uFF19]+$".toRegex())) {
          z = true
        } else {
          if (reading != "*") {
            if (isKanji(surface) || containKanji(surface)) {
              surface = KanaConverter.convertKana(reading, KanaConverter.OP_ZEN_KATA_TO_ZEN_HIRA)
            }
          }
          z = false
        }
        result += surface
      }
      return result
    }
}
