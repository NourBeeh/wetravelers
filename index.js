// index.js
import { registerRootComponent } from 'expo';
import { NativeModules } from 'react-native';
import App from './App';

// تصحيح مؤقت لـ PlatformConstants (يعمل مع newArchEnabled=false)
try {
  if (!NativeModules.PlatformConstants) {
    NativeModules.PlatformConstants = {
      getConstants: () => ({
        reactNativeVersion: '0.75.3',
        Version: 75,
        Release: '0.75.3',
        Model: 'Unknown',
        ServerHost: null,
        uiMode: 'light',
        isTesting: false,
      }),
    };
  }
} catch {
  console.warn('PlatformConstants fallback applied');
}

registerRootComponent(App);
