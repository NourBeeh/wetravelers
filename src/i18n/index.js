// src/i18n/index.js
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import * as Localization from 'expo-localization';
import AsyncStorage from '@react-native-async-storage/async-storage';
import ar from './locales/ar.json';
import en from './locales/en.json';

const resources = {
  ar: { translation: ar },
  en: { translation: en },
};

const initI18n = async () => {
  // محاولة استرجاع اللغة المخزنة
  let savedLanguage = await AsyncStorage.getItem('app-language');
  if (!savedLanguage) {
    // إذا لم توجد، استخدم لغة الجهاز أو الإنجليزية كـ fallback
    const deviceLang = Localization.locale.split('-')[0];
    savedLanguage = deviceLang === 'ar' ? 'ar' : 'en';
    await AsyncStorage.setItem('app-language', savedLanguage);
  }

  i18n.use(initReactI18next).init({
    resources,
    lng: savedLanguage,
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false,
    },
  });

  return i18n;
};

export default initI18n;