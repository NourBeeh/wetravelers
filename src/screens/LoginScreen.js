// src/screens/LoginScreen.js
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
  useColorScheme,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useAuth } from '../context/AuthContext';

export default function LoginScreen() {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const scheme = useColorScheme();
  const isDark = scheme === 'dark';
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const tr = (key, fallback = '') => {
    const value = t(key);
    return (value && typeof value === 'string') ? value : fallback;
  };

  const colors = {
    background: isDark ? '#1C1C1E' : '#F2F2F7',
    card: isDark ? '#2C2C2E' : '#FFFFFF',
    text: isDark ? '#F2F2F7' : '#1C1C1E',
    subText: isDark ? '#98989E' : '#8E8E93',
    inputBg: isDark ? '#3A3A3C' : '#E5E5EA',
    border: isDark ? 'rgba(60,60,67,0.36)' : 'rgba(60,60,67,0.08)',
    primary: isDark ? '#0A84FF' : '#007AFF',
  };

  const handleLogin = () => {
    Alert.alert(tr('common.login', 'Login'), tr('common.ok', 'OK'));
    login({ name: 'User', email: email, avatar: null });
    navigation.goBack();
  };

  const handleSocialLogin = (provider) => {
    const avatars = {
      Google: 'https://ui-avatars.com/api/?name=Google+User&background=DB4437&color=fff&size=128',
      Apple: 'https://ui-avatars.com/api/?name=Apple+User&background=000000&color=fff&size=128',
      Facebook: 'https://ui-avatars.com/api/?name=FB+User&background=1877F2&color=fff&size=128',
    };
    Alert.alert(`${tr('common.login', 'Login')} ${provider}`, tr('common.ok', 'OK'));
    login({ name: `${provider} User`, email: `${provider}@example.com`, avatar: avatars[provider] });
    navigation.goBack();
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.scrollContent}
        >
          <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
            <Ionicons name="arrow-back" size={24} color={colors.text} />
          </TouchableOpacity>

          <View style={styles.headerContainer}>
            <Text style={[styles.title, { color: colors.text }]}>
              {tr('login.title', 'Welcome Back 👋')}
            </Text>
            <Text style={[styles.subtitle, { color: colors.subText }]}>
              {tr('login.subtitle', 'Sign in to enjoy a personalized travel experience')}
            </Text>
          </View>

          <View style={styles.socialContainer}>
            <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: colors.card, borderColor: colors.border }]}
              onPress={() => handleSocialLogin('Apple')}
            >
              <Ionicons name="logo-apple" size={22} color={colors.text} />
              <Text style={[styles.socialButtonText, { color: colors.text }]}>
                {tr('login.socialApple', 'Apple')}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: colors.card, borderColor: colors.border }]}
              onPress={() => handleSocialLogin('Google')}
            >
              <Ionicons name="logo-google" size={22} color="#DB4437" />
              <Text style={[styles.socialButtonText, { color: colors.text }]}>
                {tr('login.socialGoogle', 'Google')}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: colors.card, borderColor: colors.border }]}
              onPress={() => handleSocialLogin('Facebook')}
            >
              <Ionicons name="logo-facebook" size={22} color="#1877F2" />
              <Text style={[styles.socialButtonText, { color: colors.text }]}>
                {tr('login.socialFacebook', 'Facebook')}
              </Text>
            </TouchableOpacity>
          </View>

          <View style={styles.dividerContainer}>
            <View style={[styles.dividerLine, { backgroundColor: colors.border }]} />
            <Text style={[styles.dividerText, { color: colors.subText }]}>
              {tr('login.or', 'or')}
            </Text>
            <View style={[styles.dividerLine, { backgroundColor: colors.border }]} />
          </View>

          <View style={styles.inputContainer}>
            <View style={[styles.inputWrapper, { backgroundColor: colors.inputBg }]}>
              <Ionicons name="mail-outline" size={20} color={colors.subText} style={styles.inputIcon} />
              <TextInput
                style={[styles.input, { color: colors.text }]}
                placeholder={tr('login.emailPlaceholder', 'Email')}
                placeholderTextColor={colors.subText}
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
              />
            </View>

            <View style={[styles.inputWrapper, { backgroundColor: colors.inputBg }]}>
              <Ionicons name="lock-closed-outline" size={20} color={colors.subText} style={styles.inputIcon} />
              <TextInput
                style={[styles.input, { color: colors.text }]}
                placeholder={tr('login.passwordPlaceholder', 'Password')}
                placeholderTextColor={colors.subText}
                value={password}
                onChangeText={setPassword}
                secureTextEntry={!showPassword}
                autoCapitalize="none"
              />
              <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
                <Ionicons
                  name={showPassword ? 'eye-off-outline' : 'eye-outline'}
                  size={20}
                  color={colors.subText}
                />
              </TouchableOpacity>
            </View>

            <TouchableOpacity style={styles.forgotPassword}>
              <Text style={[styles.forgotPasswordText, { color: colors.primary }]}>
                {tr('login.forgotPassword', 'Forgot Password?')}
              </Text>
            </TouchableOpacity>
          </View>

          <TouchableOpacity
            style={[styles.loginButton, { backgroundColor: colors.primary }]}
            onPress={handleLogin}
            activeOpacity={0.8}
          >
            <Text style={styles.loginButtonText}>
              {tr('login.loginButton', 'Sign In')}
            </Text>
          </TouchableOpacity>

          <View style={styles.footerContainer}>
            <Text style={[styles.footerText, { color: colors.subText }]}>
              {tr('login.noAccount', "Don't have an account?")}
            </Text>
            <TouchableOpacity>
              <Text style={[styles.footerLink, { color: colors.primary }]}>
                {' '}{tr('login.signUpLink', 'Sign Up')}
              </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  keyboardView: { flex: 1 },
  scrollContent: { paddingHorizontal: 24, paddingTop: 12, paddingBottom: 40 },
  backButton: { width: 40, height: 40, justifyContent: 'center', marginBottom: 12 },
  headerContainer: { marginBottom: 32 },
  title: { fontSize: 28, fontWeight: '700', marginBottom: 6 },
  subtitle: { fontSize: 15, fontWeight: '400' },
  socialContainer: { flexDirection: 'row', justifyContent: 'space-between', gap: 12, marginBottom: 28 },
  socialButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    borderRadius: 12,
    borderWidth: 0.5,
    gap: 8,
  },
  socialButtonText: { fontSize: 14, fontWeight: '500' },
  dividerContainer: { flexDirection: 'row', alignItems: 'center', marginBottom: 28 },
  dividerLine: { flex: 1, height: 0.5 },
  dividerText: { paddingHorizontal: 16, fontSize: 13, fontWeight: '500' },
  inputContainer: { marginBottom: 24 },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 12,
    paddingHorizontal: 14,
    marginBottom: 14,
    height: 50,
  },
  inputIcon: { marginRight: 10 },
  input: { flex: 1, fontSize: 16, fontWeight: '400' },
  forgotPassword: { alignSelf: 'flex-end' },
  forgotPasswordText: { fontSize: 13, fontWeight: '500' },
  loginButton: { height: 50, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginBottom: 14 },
  loginButtonText: { color: '#FFFFFF', fontSize: 16, fontWeight: '600' },
  footerContainer: { flexDirection: 'row', justifyContent: 'center', marginTop: 8 },
  footerText: { fontSize: 14, fontWeight: '400' },
  footerLink: { fontSize: 14, fontWeight: '500' },
});