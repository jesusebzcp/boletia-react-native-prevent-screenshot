import { Platform, StyleSheet, View } from 'react-native';
import type { PreventScreenshotViewProps } from './types';
import {
  PreventScreenshotModuleAndroid,
  PreventScreenshotViewModule,
} from './PreventScreenshotViewModule';
import { useEffect } from 'react';

export const PreventScreenshotView = ({
  style,
  image,
  children,
  backgroundColor,
  resizeMode,
}: PreventScreenshotViewProps) => {
  useEffect(() => {
    if (Platform.OS !== 'android') {
      return;
    }
    PreventScreenshotModuleAndroid.enabled(true);

    return () => {
      PreventScreenshotModuleAndroid.disableSecureView();
      PreventScreenshotModuleAndroid.enabled(false);
    };
  }, [image]);

  if (Platform.OS === 'android') {
    return <View style={[styles.container]}>{children}</View>;
  }

  return (
    <PreventScreenshotViewModule
      style={style ?? {}}
      image={image}
      resizeMode={resizeMode}
    >
      <View
        style={[
          styles.container,
          style,
          {
            backgroundColor: backgroundColor ?? '#f2f2f2',
          },
        ]}
      >
        {children}
      </View>
    </PreventScreenshotViewModule>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
