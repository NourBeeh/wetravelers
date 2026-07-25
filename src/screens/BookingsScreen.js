// src/screens/BookingsScreen.js
import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, useColorScheme } from 'react-native';
import { useTranslation } from 'react-i18next';

export default function BookingsScreen() {
  const { t } = useTranslation();
  const scheme = useColorScheme();
  const isDark = scheme === 'dark';

  const colors = {
    background: isDark ? '#1C1C1E' : '#F2F2F7',
    text: isDark ? '#F2F2F7' : '#1C1C1E',
    subText: isDark ? '#98989E' : '#8E8E93',
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <View style={styles.content}>
        <Text style={styles.emoji}>📅</Text>
        <Text style={[styles.title, { color: colors.text }]}>{t('bookings.title')}</Text>
        <Text style={[styles.subtitle, { color: colors.subText }]}>{t('bookings.subtitle')}</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 20 },
  emoji: { fontSize: 48, marginBottom: 16 },
  title: { fontSize: 24, fontWeight: '600', marginBottom: 8 },
  subtitle: { fontSize: 16, fontWeight: '400' },
});