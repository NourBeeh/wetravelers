// src/screens/HomeScreen.js
import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  SafeAreaView,
  StatusBar,
  Image,
  TouchableOpacity,
  Dimensions,
  useColorScheme,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../context/AuthContext';

const { width } = Dimensions.get('window');

const CARD_WIDTH = width - 32;
const CARD_HEIGHT = 440;
const IMAGE_HEIGHT = 280;
const CORNER_RADIUS = 20;

const HOTEL_COLORS = ['#3D2B1F', '#2C1810', '#1A1108', '#4A3728', '#2F1B0E'];
const FLIGHT_COLORS = ['#2C1C13', '#3D2B1F', '#1A1108', '#4A3728', '#2F1B0E'];

export default function HomeScreen() {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const scheme = useColorScheme();
  const isDark = scheme === 'dark';
  const insets = useSafeAreaInsets();
  const { user } = useAuth();

  const [isFlightExpanded, setIsFlightExpanded] = useState(false);
  const [hotelImageIndex, setHotelImageIndex] = useState(0);
  const [refreshing, setRefreshing] = useState(false);

  const colors = {
    background: isDark ? '#1C1C1E' : '#FFFFFF',
    text: isDark ? '#F2F2F7' : '#000000',
    subText: isDark ? '#98989E' : '#8E8E93',
    buttonBg: isDark ? 'rgba(10, 132, 255, 0.15)' : 'rgba(0, 122, 255, 0.1)',
    buttonBorder: isDark ? 'rgba(10, 132, 255, 0.3)' : 'rgba(0, 122, 255, 0.2)',
  };

  const hotelImages = [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&h=600&fit=crop',
  ];

  const flightImage =
    'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&h=600&fit=crop';

  const onRefresh = () => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 1500);
  };

  return (
    <SafeAreaView style={[styles.safeArea, { backgroundColor: colors.background }]}>
      <StatusBar barStyle={isDark ? 'light-content' : 'dark-content'} />

      <View style={[styles.headerContainer, { paddingTop: insets.top + 12 }]}>
        <View>
          <Text style={[styles.appNameText, { color: colors.subText }]}>
            {t('home.weTravelers')}
          </Text>
          <Text style={[styles.todayText, { color: colors.text }]}>
            {t('home.today')}
          </Text>
        </View>

        <TouchableOpacity
          style={[
            styles.profileAvatarContainer,
            {
              backgroundColor: colors.buttonBg,
              borderColor: colors.buttonBorder,
            },
          ]}
          onPress={() => navigation.navigate('الملف الشخصي')}
          activeOpacity={0.7}
        >
          {user?.avatar ? (
            <Image source={{ uri: user.avatar }} style={styles.avatarImage} />
          ) : (
            <Ionicons name="person-outline" size={20} color="#007AFF" />
          )}
        </TouchableOpacity>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContainer}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.text}
            colors={[colors.text]}
            progressBackgroundColor={colors.background}
          />
        }
      >
        {/* ===== كارت الفنادق ===== */}
        <View style={[styles.card, { backgroundColor: HOTEL_COLORS[0] }]}>
          <View style={styles.imageContainer}>
            <Image
              source={{ uri: hotelImages[hotelImageIndex] }}
              style={styles.image}
              resizeMode="cover"
            />
          </View>

          <LinearGradient
            colors={[
              'rgba(26, 17, 8, 0.0)',
              'rgba(26, 17, 8, 0.0)',
              'rgba(26, 17, 8, 0.85)',
              '#1A1108',
            ]}
            locations={[0, 0.5, 0.7, 1]}
            style={StyleSheet.absoluteFillObject}
          />

          <View style={styles.hotelTabsRow}>
            <TouchableOpacity
              style={[styles.hotelTabButton, hotelImageIndex === 0 && styles.hotelTabActive]}
              onPress={() => setHotelImageIndex(0)}
            >
              <Text style={styles.hotelTabText}>{t('home.hotelCard.room')}</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.hotelTabButton, hotelImageIndex === 1 && styles.hotelTabActive]}
              onPress={() => setHotelImageIndex(1)}
            >
              <Text style={styles.hotelTabText}>{t('home.hotelCard.view')}</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.mainContainer}>
            <View style={styles.contentContainer}>
              <View style={styles.tagContainer}>
                <Text style={styles.tagText}>{t('home.hotelCard.tag')}</Text>
              </View>
              <Text style={styles.subtitleText}>{t('home.hotelCard.subtitle')}</Text>
              <Text style={styles.titleText}>{t('home.hotelCard.title')}</Text>
              <Text style={styles.descriptionText}>
                {t('home.hotelCard.description')}
              </Text>
            </View>

            <View style={styles.bottomRow}>
              <View style={styles.appIconContainer}>
                <View style={[styles.appIcon, { backgroundColor: '#FF9500' }]}>
                  <Text style={styles.appIconText}>H</Text>
                </View>
              </View>
              <View style={styles.appInfo}>
                <Text style={styles.appName}>{t('home.hotelCard.appName')}</Text>
                <Text style={styles.appCategory}>{t('home.hotelCard.appCategory')}</Text>
              </View>
              <View style={styles.getButtonContainer}>
                <TouchableOpacity style={styles.getButton}>
                  <Text style={styles.getButtonText}>{t('home.getButton')}</Text>
                </TouchableOpacity>
                <Text style={styles.inAppText}>{t('home.inAppPurchases')}</Text>
              </View>
            </View>
          </View>
        </View>

        {/* ===== كارت الطيران ===== */}
        <TouchableOpacity
          style={[
            styles.card,
            {
              backgroundColor: FLIGHT_COLORS[0],
              height: isFlightExpanded ? 520 : CARD_HEIGHT,
            },
          ]}
          activeOpacity={0.95}
          onPress={() => setIsFlightExpanded(!isFlightExpanded)}
        >
          <View style={styles.imageContainer}>
            <Image source={{ uri: flightImage }} style={styles.image} resizeMode="cover" />
          </View>

          <LinearGradient
            colors={[
              'rgba(44, 28, 19, 0.0)',
              'rgba(44, 28, 19, 0.0)',
              'rgba(44, 28, 19, 0.85)',
              '#2C1C13',
            ]}
            locations={[0, 0.5, 0.7, 1]}
            style={StyleSheet.absoluteFillObject}
          />

          <View style={styles.mainContainer}>
            <View style={styles.contentContainer}>
              <View style={styles.tagContainer}>
                <Text style={styles.tagText}>{t('home.flightCard.tag')}</Text>
              </View>
              <Text style={styles.subtitleText}>{t('home.flightCard.subtitle')}</Text>
              <Text style={styles.titleText}>{t('home.flightCard.title')}</Text>

              <View style={styles.timelineWrapper}>
                <Text style={styles.timelineLocation}>{t('home.flightCard.departure')}</Text>
                <View style={styles.timelineTrack}>
                  <View style={styles.timelineDot} />
                  <View style={styles.timelineBar} />
                  <View style={[styles.timelineDot, { backgroundColor: '#FF3B30' }]} />
                  <View style={styles.timelineBar} />
                  <View style={styles.timelineDot} />
                </View>
                <Text style={styles.timelineLocation}>{t('home.flightCard.arrival')}</Text>
              </View>

              {isFlightExpanded && (
                <View style={styles.explodedDetails}>
                  <Text style={styles.explodedText}>{t('home.flightCard.expanded1')}</Text>
                  <Text style={styles.explodedText}>{t('home.flightCard.expanded2')}</Text>
                </View>
              )}
            </View>

            <View style={styles.bottomRow}>
              <View style={styles.appIconContainer}>
                <View style={[styles.appIcon, { backgroundColor: '#5856D6' }]}>
                  <Text style={styles.appIconText}>F</Text>
                </View>
              </View>
              <View style={styles.appInfo}>
                <Text style={styles.appName}>{t('home.flightCard.appName')}</Text>
                <Text style={styles.appCategory}>{t('home.flightCard.appCategory')}</Text>
              </View>
              <View style={styles.getButtonContainer}>
                <TouchableOpacity style={styles.getButton}>
                  <Text style={styles.getButtonText}>{t('home.getButton')}</Text>
                </TouchableOpacity>
                <Text style={styles.inAppText}>{t('home.inAppPurchases')}</Text>
              </View>
            </View>
          </View>
        </TouchableOpacity>

        <View style={styles.bottomSpacer} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingBottom: 16,
  },
  appNameText: {
    fontSize: 13,
    fontWeight: '600',
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },
  todayText: {
    fontSize: 34,
    fontWeight: '700',
    letterSpacing: 0.5,
    marginTop: 0,
  },
  profileAvatarContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 0.5,
    overflow: 'hidden',
  },
  avatarImage: { width: 36, height: 36, borderRadius: 18 },
  scrollContainer: { paddingBottom: 20, paddingHorizontal: 16 },
  card: {
    width: CARD_WIDTH,
    height: CARD_HEIGHT,
    borderRadius: CORNER_RADIUS,
    overflow: 'hidden',
    marginBottom: 24,
    alignSelf: 'center',
    position: 'relative',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.3,
    shadowRadius: 12,
    elevation: 6,
  },
  imageContainer: {
    width: CARD_WIDTH,
    height: IMAGE_HEIGHT,
    position: 'absolute',
    top: 0,
    left: 0,
    overflow: 'hidden',
  },
  image: { width: '100%', height: '100%' },
  mainContainer: { flex: 1, justifyContent: 'flex-end' },
  contentContainer: { paddingHorizontal: 16, marginBottom: 12 },
  tagContainer: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 12,
    paddingHorizontal: 10,
    paddingVertical: 4,
    alignSelf: 'flex-start',
    marginBottom: 8,
  },
  tagText: { color: '#FFFFFF', fontSize: 11, fontWeight: '600' },
  subtitleText: {
    fontSize: 12,
    fontWeight: '600',
    color: 'rgba(255,255,255,0.55)',
    textTransform: 'uppercase',
    marginBottom: 2,
    textAlign: 'left',
  },
  titleText: {
    color: '#FFFFFF',
    fontSize: 26,
    fontWeight: 'bold',
    marginBottom: 6,
    lineHeight: 32,
    textAlign: 'left',
  },
  descriptionText: {
    color: 'rgba(255,255,255,0.75)',
    fontSize: 15,
    fontWeight: '400',
    lineHeight: 20,
    textAlign: 'left',
  },
  hotelTabsRow: {
    flexDirection: 'row',
    position: 'absolute',
    top: 16,
    right: 16,
    backgroundColor: 'rgba(0,0,0,0.5)',
    borderRadius: 12,
    padding: 2,
    zIndex: 10,
  },
  hotelTabButton: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 10 },
  hotelTabActive: { backgroundColor: 'rgba(255,255,255,0.25)' },
  hotelTabText: { color: '#FFFFFF', fontSize: 11, fontWeight: '600' },
  timelineWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 10,
    backgroundColor: 'rgba(255,255,255,0.05)',
    padding: 8,
    borderRadius: 10,
  },
  timelineLocation: { color: '#FFFFFF', fontWeight: 'bold', fontSize: 14 },
  timelineTrack: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 10,
  },
  timelineDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: '#34C759' },
  timelineBar: {
    flex: 1,
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.2)',
    marginHorizontal: 4,
  },
  explodedDetails: {
    marginTop: 10,
    backgroundColor: 'rgba(0,0,0,0.2)',
    padding: 10,
    borderRadius: 8,
  },
  explodedText: { color: 'rgba(255,255,255,0.7)', fontSize: 13, marginBottom: 4, textAlign: 'left' },
  bottomRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: 'rgba(0,0,0,0.2)',
    borderTopWidth: 0.5,
    borderTopColor: 'rgba(255,255,255,0.08)',
  },
  appIconContainer: { marginRight: 12 },
  appIcon: {
    width: 60,
    height: 60,
    borderRadius: 13,
    justifyContent: 'center',
    alignItems: 'center',
  },
  appIconText: { fontSize: 28, fontWeight: '700', color: '#FFFFFF' },
  appInfo: { flex: 1, justifyContent: 'center' },
  appName: { fontSize: 16, fontWeight: '600', color: '#FFFFFF', marginBottom: 2, textAlign: 'left' },
  appCategory: {
    fontSize: 12,
    fontWeight: '400',
    color: 'rgba(255,255,255,0.5)',
    textAlign: 'left',
  },
  getButtonContainer: { alignItems: 'center', marginLeft: 8 },
  getButton: {
    backgroundColor: '#FFFFFF',
    width: 74,
    height: 28,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
  },
  getButtonText: { color: '#007AFF', fontSize: 14, fontWeight: 'bold' },
  inAppText: {
    color: 'rgba(255,255,255,0.4)',
    fontSize: 8,
    marginTop: 3,
    textAlign: 'center',
  },
  bottomSpacer: { height: 20 },
});