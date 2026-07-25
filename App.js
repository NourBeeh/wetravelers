// App.js
import React, { useEffect, useState } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { I18nextProvider } from 'react-i18next';
import AppNavigator from './src/navigation/AppNavigator';
import { AuthProvider } from './src/context/AuthContext';
import initI18n from './src/i18n';

export default function App() {
  const [i18n, setI18n] = useState(null);

  useEffect(() => {
    initI18n().then(setI18n);
  }, []);

  if (!i18n) return null;

  return (
    <I18nextProvider i18n={i18n}>
      <SafeAreaProvider>
        <NavigationContainer>
          <AuthProvider>   {/* ✅ هذا هو المفتاح */}
            <AppNavigator />
          </AuthProvider>
        </NavigationContainer>
      </SafeAreaProvider>
    </I18nextProvider>
  );
}