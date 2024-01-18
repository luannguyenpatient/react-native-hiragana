import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-hiragana' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const Hiragana = NativeModules.Hiragana
  ? NativeModules.Hiragana
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function convert(str: string): Promise<string> {
  return Hiragana.convert(str);
}
