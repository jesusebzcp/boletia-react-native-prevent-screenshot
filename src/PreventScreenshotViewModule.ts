import {
  requireNativeComponent,
  UIManager,
  Platform,
  NativeModules,
} from 'react-native';
import type {
  PreventScreenshotModuleAndroidTypes,
  PreventScreenshotProps,
} from './types';

const LINKING_ERROR =
  `The package 'react-native-prevent-screenshot' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ComponentName = 'PreventScreenshotView';

// Para iOS, usa un componente nativo si está disponible
export const PreventScreenshotViewModule =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<PreventScreenshotProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };

export const PreventScreenshotModuleAndroid: PreventScreenshotModuleAndroidTypes =
  NativeModules.RNScreenshotPrevent
    ? NativeModules.RNScreenshotPrevent
    : new Proxy(
        {},
        {
          get() {
            throw new Error(LINKING_ERROR);
          },
        }
      );
