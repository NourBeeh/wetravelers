// src/navigation/AppNavigator.js
import React from 'react';
import { StyleSheet, useColorScheme } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTranslation } from 'react-i18next';

import HomeScreen from '../screens/HomeScreen';
import SearchScreen from '../screens/SearchScreen';
import AIScreen from '../screens/AIScreen';
import BookingsScreen from '../screens/BookingsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import LoginScreen from '../screens/LoginScreen';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

const getColors = (scheme) => {
  const isDark = scheme === 'dark';
  return {
    activeTint: isDark ? '#0A84FF' : '#007AFF',
    inactiveTint: isDark ? '#98989E' : '#8E8E93',
    background: isDark ? 'rgba(28,28,30,0.95)' : 'rgba(255,255,255,0.95)',
    borderColor: isDark ? 'rgba(60,60,67,0.36)' : 'rgba(60,60,67,0.08)',
    labelColor: isDark ? '#F2F2F7' : '#1C1C1E',
    iconSize: 25,
  };
};

function MainTabs() {
  const { t } = useTranslation();
  const scheme = useColorScheme();
  const colors = getColors(scheme);
  const insets = useSafeAreaInsets();

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarIcon: ({ focused, color }) => {
          let iconName;
          if (route.name === 'Today') {
            iconName = focused ? 'today' : 'today-outline';
          } else if (route.name === t('common.search')) {
            iconName = focused ? 'search' : 'search-outline';
          } else if (route.name === t('common.ai')) {
            iconName = focused ? 'sparkles' : 'sparkles-outline';
          } else if (route.name === t('common.bookings')) {
            iconName = focused ? 'calendar' : 'calendar-outline';
          } else if (route.name === t('common.profile')) {
            iconName = focused ? 'person' : 'person-outline';
          }
          return <Ionicons name={iconName} size={colors.iconSize} color={color} />;
        },
        tabBarActiveTintColor: colors.activeTint,
        tabBarInactiveTintColor: colors.inactiveTint,
        tabBarLabelStyle: {
          fontSize: 10,
          fontWeight: '500',
          fontFamily: 'System',
          color: colors.labelColor,
        },
        tabBarStyle: {
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          height: 49 + insets.bottom,
          paddingBottom: insets.bottom / 2,
          backgroundColor: colors.background,
          borderTopWidth: 0.5,
          borderTopColor: colors.borderColor,
        },
      })}
    >
      <Tab.Screen name="Today" component={HomeScreen} />
      <Tab.Screen name={t('common.search')} component={SearchScreen} />
      <Tab.Screen name={t('common.ai')} component={AIScreen} />
      <Tab.Screen name={t('common.bookings')} component={BookingsScreen} />
      <Tab.Screen name={t('common.profile')} component={ProfileScreen} />
    </Tab.Navigator>
  );
}

export default function AppNavigator() {
  const scheme = useColorScheme();
  const colors = getColors(scheme);

  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        contentStyle: {
          backgroundColor: colors.background,
        },
      }}
    >
      <Stack.Screen name="MainTabs" component={MainTabs} />
      <Stack.Screen name="Login" component={LoginScreen} />
    </Stack.Navigator>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#F2F2F7' },
  screenText: { fontSize: 24, fontWeight: '600', color: '#1C1C1E' },
});