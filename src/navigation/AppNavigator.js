// src/navigation/AppNavigator.js
import React from 'react';
import { StyleSheet, Text, useColorScheme } from 'react-native';
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
    activeTint: isDark ? '#0A84FF' : '#0064FF',
    inactiveTint: isDark ? '#98989E' : '#8E8E93',
    background: isDark ? '#0B0C10' : '#FFFFFF',
    borderColor: isDark ? 'rgba(60,60,67,0.36)' : 'rgba(60,60,67,0.08)',
    labelColor: isDark ? '#F2F2F7' : '#1C1C1E',
    iconSize: 22,
  };
};

function MainTabs() {
  const { t } = useTranslation();
  const scheme = useColorScheme();
  const colors = getColors(scheme);
  const insets = useSafeAreaInsets();

  const TAB_NAMES = {
    today: 'Today',
    search: 'Search',
    ai: 'AI',
    bookings: 'Bookings',
    profile: 'Profile',
  };

  const tr = (key, fallback = '') => {
    const value = t(key);
    return (value && typeof value === 'string') ? value : fallback;
  };

  const tabLabels = {
    today: tr('home.today', 'Today'),
    search: tr('common.search', 'Search'),
    ai: tr('common.ai', 'AI Assistant'),
    bookings: tr('common.bookings', 'Bookings'),
    profile: tr('common.profile', 'Profile'),
  };

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarIcon: ({ focused, color }) => {
          let iconName;
          if (route.name === TAB_NAMES.today) {
            iconName = focused ? 'today' : 'today-outline';
          } else if (route.name === TAB_NAMES.search) {
            iconName = focused ? 'search' : 'search-outline';
          } else if (route.name === TAB_NAMES.ai) {
            iconName = focused ? 'sparkles' : 'sparkles-outline';
          } else if (route.name === TAB_NAMES.bookings) {
            iconName = focused ? 'calendar' : 'calendar-outline';
          } else if (route.name === TAB_NAMES.profile) {
            iconName = focused ? 'person' : 'person-outline';
          }
          return <Ionicons name={iconName} size={colors.iconSize} color={color} />;
        },
        tabBarActiveTintColor: colors.activeTint,
        tabBarInactiveTintColor: colors.inactiveTint,
        tabBarLabel: ({ focused, color }) => {
          let label = '';
          if (route.name === TAB_NAMES.today) label = tabLabels.today;
          else if (route.name === TAB_NAMES.search) label = tabLabels.search;
          else if (route.name === TAB_NAMES.ai) label = tabLabels.ai;
          else if (route.name === TAB_NAMES.bookings) label = tabLabels.bookings;
          else if (route.name === TAB_NAMES.profile) label = tabLabels.profile;

          return (
            <Text style={{ color, fontSize: 11, fontWeight: '500' }}>
              {label}
            </Text>
          );
        },
        tabBarStyle: {
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          height: 40 + insets.bottom,
          paddingBottom: insets.bottom,
          backgroundColor: colors.background,
          borderTopWidth: 0,
          borderTopColor: 'transparent',
          shadowOpacity: 0,
          shadowOffset: { width: 0, height: 0 },
          shadowRadius: 0,
          elevation: 0,
        },
      })}
    >
      <Tab.Screen name={TAB_NAMES.today} component={HomeScreen} />
      <Tab.Screen name={TAB_NAMES.search} component={SearchScreen} />
      <Tab.Screen name={TAB_NAMES.ai} component={AIScreen} />
      <Tab.Screen name={TAB_NAMES.bookings} component={BookingsScreen} />
      <Tab.Screen name={TAB_NAMES.profile} component={ProfileScreen} />
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