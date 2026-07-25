// index.js
import { NativeModules } from 'react-native';

// ✅ تصحيح مؤقت لـ PlatformConstants (يعمل مع newArchEnabled=false)
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
} catch (e) {
  console.warn('PlatformConstants fallback applied');
}

import { registerRootComponent } from 'expo';
import App from './App';

registerRootComponent(App);