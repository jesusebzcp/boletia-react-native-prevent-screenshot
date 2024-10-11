import type { ImageResizeMode, ViewStyle } from 'react-native';

export type PreventScreenshotProps = {
  style: ViewStyle;
  image: string;
  children: any;
  resizeMode?: ImageResizeMode;
};

export type PreventScreenshotViewProps = {
  style?: ViewStyle;
  image: string;
  children: any;
  backgroundColor?: string;
  preventScreenshot?: boolean;
  resizeMode?: ImageResizeMode;
};

export type PreventScreenshotModuleAndroidTypes = {
  enabled: (enable: boolean) => Promise<void>; // Habilita o deshabilita la protección contra capturas de pantalla
  enableSecureView: (imagePath: string) => Promise<void>; // Habilita la vista segura con una imagen
  disableSecureView: () => Promise<void>; // Deshabilita la vista segura
};
