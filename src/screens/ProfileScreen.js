// src/screens/ProfileScreen.js
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  useColorScheme,
  Alert,
  ScrollView,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAuth } from '../context/AuthContext';
import AsyncStorage from '@react-native-async-storage/async-storage';
import i18n from 'i18next';

export default function ProfileScreen() {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const scheme = useColorScheme();
  const isDark = scheme === 'dark';
  const insets = useSafeAreaInsets();
  const { user, login, logout } = useAuth();

  const colors = {
    background: isDark ? '#1C1C1E' : '#F2F2F7',
    card: isDark ? '#2C2C2E' : '#FFFFFF',
    text: isDark ? '#F2F2F7' : '#1C1C1E',
    subText: isDark ? '#98989E' : '#8E8E93',
    primary: isDark ? '#0A84FF' : '#007AFF',
    border: isDark ? 'rgba(60,60,67,0.36)' : 'rgba(60,60,67,0.08)',
  };

  const currentLanguage = i18n.language;

  const toggleLanguage = async () => {
    const newLang = currentLanguage === 'ar' ? 'en' : 'ar';
    await AsyncStorage.setItem('app-language', newLang);
    i18n.changeLanguage(newLang);
  };

  const handleLogout = () => {
    Alert.alert(
      t('profile.logoutConfirm'),
      '',
      [
        { text: t('common.cancel'), style: 'cancel' },
        {
          text: t('common.logout'),
          style: 'destructive',
          onPress: () => {
            logout();
            navigation.goBack();
          },
        },
      ]
    );
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>

        <Text style={[styles.title, { color: colors.text }]}>{t('profile.title')}</Text>

        {/* قسم تسجيل الدخول */}
        <View style={[styles.section, { backgroundColor: colors.card, borderColor: colors.border }]}>
          {user ? (
            <View style={styles.userInfo}>
              <View style={styles.avatarLarge}>
                <Text style={styles.avatarText}>U</Text>
              </View>
              <Text style={[styles.userName, { color: colors.text }]}>
                {user.name || t('profile.loggedInAs')}
              </Text>
              <TouchableOpacity
                style={[styles.logoutButton, { borderColor: colors.border }]}
                onPress={handleLogout}
              >
                <Text style={[styles.logoutText, { color: colors.primary }]}>
                  {t('common.logout')}
                </Text>
              </TouchableOpacity>
            </View>
          ) : (
            <TouchableOpacity
              style={styles.loginSection}
              onPress={() => navigation.navigate('Login')}
            >
              <Text style={[styles.loginPrompt, { color: colors.text }]}>
                {t('profile.loginPrompt')}
              </Text>
              <View style={[styles.loginButton, { backgroundColor: colors.primary }]}>
                <Text style={styles.loginButtonText}>{t('common.login')}</Text>
              </View>
            </TouchableOpacity>
          )}
        </View>

        {/* قسم التحكم في اللغة */}
        <View style={[styles.section, { backgroundColor: colors.card, borderColor: colors.border }]}>
          <View style={styles.languageRow}>
            <Ionicons name="language-outline" size={22} color={colors.subText} />
            <Text style={[styles.languageLabel, { color: colors.text }]}>
              {t('profile.languageSetting')}
            </Text>
            <View style={styles.languageToggle}>
              <TouchableOpacity
                style={[
                  styles.langOption,
                  currentLanguage === 'ar' && styles.langOptionActive,
                  { borderColor: colors.border },
                ]}
                onPress={toggleLanguage}
              >
                <Text
                  style={[
                    styles.langText,
                    currentLanguage === 'ar' && styles.langTextActive,
                    { color: currentLanguage === 'ar' ? colors.primary : colors.subText },
                  ]}
                >
                  {t('common.arabic')}
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[
                  styles.langOption,
                  currentLanguage === 'en' && styles.langOptionActive,
                  { borderColor: colors.border },
                ]}
                onPress={toggleLanguage}
              >
                <Text
                  style={[
                    styles.langText,
                    currentLanguage === 'en' && styles.langTextActive,
                    { color: currentLanguage === 'en' ? colors.primary : colors.subText },
                  ]}
                >
                  {t('common.english')}
                </Text>
              </TouchableOpacity>
            </View>
          </View>
          <Text style={[styles.currentLangText, { color: colors.subText }]}>
            {t('profile.currentLanguage')}: {currentLanguage === 'ar' ? 'العربية' : 'English'}
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scrollContent: { paddingHorizontal: 24, paddingTop: 12, paddingBottom: 40 },
  backButton: { width: 40, height: 40, justifyContent: 'center', marginBottom: 12 },
  title: { fontSize: 28, fontWeight: '700', marginBottom: 24 },
  section: { borderRadius: 16, padding: 16, marginBottom: 20, borderWidth: 0.5 },
  userInfo: { alignItems: 'center', paddingVertical: 8 },
  avatarLarge: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  avatarText: { color: '#FFFFFF', fontSize: 32, fontWeight: 'bold' },
  userName: { fontSize: 18, fontWeight: '600', marginBottom: 12 },
  logoutButton: { paddingVertical: 8, paddingHorizontal: 20, borderRadius: 20, borderWidth: 0.5 },
  logoutText: { fontSize: 14, fontWeight: '500' },
  loginSection: { alignItems: 'center', paddingVertical: 8 },
  loginPrompt: { fontSize: 16, marginBottom: 16, textAlign: 'center' },
  loginButton: { paddingVertical: 10, paddingHorizontal: 32, borderRadius: 12 },
  loginButtonText: { color: '#FFFFFF', fontSize: 16, fontWeight: '600' },
  languageRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
  languageLabel: { fontSize: 16, fontWeight: '500', marginLeft: 10, flex: 1 },
  languageToggle: { flexDirection: 'row' },
  langOption: { paddingHorizontal: 12, paddingVertical: 4, borderRadius: 12, borderWidth: 0.5, marginLeft: 6 },
  langOptionActive: { backgroundColor: 'rgba(0, 122, 255, 0.1)' },
  langText: { fontSize: 12, fontWeight: '500' },
  langTextActive: { fontWeight: '600' },
  currentLangText: { fontSize: 13, marginTop: 4 },
});