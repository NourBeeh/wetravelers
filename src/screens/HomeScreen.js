// src/screens/HomeScreen.js
import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  StatusBar,
  Image,
  TouchableOpacity,
  useColorScheme,
  Modal,
  ScrollView,
  Dimensions,
  SafeAreaView,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../context/AuthContext';
import AppStoreCard from '../components/AppStoreCard';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

export default function HomeScreen() {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const scheme = useColorScheme();
  const isDark = scheme === 'dark';
  const insets = useSafeAreaInsets();
  const { user } = useAuth();

  const [hotelImageIndex, setHotelImageIndex] = useState(0);
  const [isFlightExpanded, setIsFlightExpanded] = useState(false);
  // ===== حالة النافذة المنبثقة =====
  const [modalVisible, setModalVisible] = useState(false);
  const [selectedCard, setSelectedCard] = useState(null);
  const [activeImageIndex, setActiveImageIndex] = useState(0);

  const colors = {
    background: isDark ? '#0B0C10' : '#FFFFFF',
    text: isDark ? '#F2F2F7' : '#000000',
    subText: isDark ? '#8E8E93' : '#6C6C70',
    cardHotelBg: '#2C1D18',
    cardFlightBg: '#132232',
    metaBlue: '#0064FF',
  };

  const tr = (key, fallback = '') => {
    const value = t(key);
    return (value && typeof value === 'string') ? value : fallback;
  };

  const hotelData = {
    id: 'hotel',
    title: tr('home.hotelCard.title', 'Luxury Resort & Spa'),
    subtitle: tr('home.hotelCard.subtitle', 'EXCLUSIVE OFFER'),
    description: tr('home.hotelCard.description', 'Experience world-class service in Cairo.'),
    tag: tr('home.hotelCard.tag', 'FEATURED'),
    images: [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&h=600&fit=crop',
    ],
    appName: tr('home.hotelCard.appName', 'Four Seasons'),
    appCategory: tr('home.hotelCard.appCategory', 'Hotel & Resort'),
    // ✅ تم إزالة appIcon
    buttonText: 'BOOK', // ✅ تغيير إلى BOOK
    backgroundColor: colors.cardHotelBg,
  };

  const flightData = {
    id: 'flight',
    title: tr('home.flightCard.title', 'Direct Flight to Europe'),
    subtitle: tr('home.flightCard.subtitle', 'BEST PRICE'),
    description: tr('home.flightCard.description', 'Fly with comfort and luxury airlines.'),
    tag: tr('home.flightCard.tag', 'POPULAR'),
    images: [
      'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800&h=600&fit=crop',
    ],
    appName: tr('home.flightCard.appName', 'WE Airways'),
    appCategory: tr('home.flightCard.appCategory', 'Flight Booking'),
    // ✅ تم إزالة appIcon
    buttonText: 'BOOK', // ✅ BOOK
    backgroundColor: colors.cardFlightBg,
  };

  // ===== فتح النافذة المنبثقة =====
  const handleOpenModal = (data) => {
    setSelectedCard(data);
    setActiveImageIndex(0);
    setModalVisible(true);
  };

  const HEADER_HEIGHT = 58;
  const BOTTOM_SPACER = insets.bottom + 70;

  // ✅ خلفية الشريط العلوي
  const headerBgColor = isDark
    ? 'rgba(11, 12, 16, 0.95)'
    : 'rgba(255, 255, 255, 0.98)';

  return (
    <SafeAreaView style={[styles.safeArea, { backgroundColor: colors.background }]}>
      <StatusBar barStyle={isDark ? 'light-content' : 'dark-content'} />

      {/* ===== الشريط العلوي ===== */}
      <View
        style={[
          styles.headerWrapper,
          {
            height: HEADER_HEIGHT,
            paddingTop: insets.top,
            backgroundColor: headerBgColor,
          },
        ]}
        pointerEvents="box-none"
      >
        <View style={styles.headerContainer}>
          <View style={styles.headerLeftText}>
            <Text style={[styles.headerTitleText, { color: colors.metaBlue }]}>
              We Traveler's
            </Text>
          </View>

          <TouchableOpacity
            style={styles.profileAvatarContainer}
            onPress={() => navigation.navigate('Profile')}
            activeOpacity={0.7}
          >
            {user?.avatar ? (
              <Image source={{ uri: user.avatar }} style={styles.avatarImage} />
            ) : (
              <View style={styles.profileIconWrapper}>
                <Ionicons name="person-outline" size={22} color={colors.metaBlue} />
              </View>
            )}
          </TouchableOpacity>
        </View>
      </View>

      {/* ===== المحتوى ===== */}
      <ScrollView
        contentContainerStyle={[
          styles.scrollContainer,
          {
            paddingTop: HEADER_HEIGHT + insets.top + 4,
            backgroundColor: colors.background,
          },
        ]}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.cardsWrapper}>
          {/* ===== كارت الفندق ===== */}
          <AppStoreCard
            key="hotel"
            backgroundColor={hotelData.backgroundColor}
            image={hotelData.images[hotelImageIndex]}
            tag={hotelData.tag}
            subtitle={hotelData.subtitle}
            title={hotelData.title}
            description={hotelData.description}
            buttonText={hotelData.buttonText}
            onPress={() => {}}
            onLongPress={() => handleOpenModal(hotelData)}
            extraControls={
              <View style={styles.hotelTabsRow}>
                <TouchableOpacity style={[styles.hotelTabButton, hotelImageIndex === 0 && styles.hotelTabActive]} onPress={() => setHotelImageIndex(0)}>
                  <Text style={styles.hotelTabText}>{tr('home.hotelCard.room', 'Room')}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.hotelTabButton, hotelImageIndex === 1 && styles.hotelTabActive]} onPress={() => setHotelImageIndex(1)}>
                  <Text style={styles.hotelTabText}>{tr('home.hotelCard.view', 'View')}</Text>
                </TouchableOpacity>
              </View>
            }
          />

          {/* ===== كارت الطيران ===== */}
          <AppStoreCard
            key="flight"
            backgroundColor={flightData.backgroundColor}
            image={flightData.images[0]}
            tag={flightData.tag}
            subtitle={flightData.subtitle}
            title={flightData.title}
            description={flightData.description}
            buttonText={flightData.buttonText}
            onPress={() => {}}
            onLongPress={() => handleOpenModal(flightData)}
            extraContent={
              <TouchableOpacity style={styles.timelineWrapper} onPress={() => setIsFlightExpanded(!isFlightExpanded)} activeOpacity={0.8}>
                <Text style={styles.timelineLocation}>{tr('home.flightCard.departure', 'CAI')}</Text>
                <View style={styles.timelineTrack}>
                  <View style={styles.timelineDot} />
                  <View style={styles.timelineBar} />
                  <Ionicons name="airplane" size={14} color="#FFFFFF" />
                  <View style={styles.timelineBar} />
                  <View style={styles.timelineDot} />
                </View>
                <Text style={styles.timelineLocation}>{tr('home.flightCard.arrival', 'CDG')}</Text>
              </TouchableOpacity>
            }
          />
        </View>

        <View style={{ height: BOTTOM_SPACER }} />
      </ScrollView>

      {/* ================================================================
          النافذة المنبثقة (PageSheet)
          ================================================================ */}
      <Modal
        visible={modalVisible}
        animationType="slide"
        presentationStyle="pageSheet"
        onRequestClose={() => setModalVisible(false)}
      >
        {selectedCard && (
          <View style={[styles.modalContainer, { backgroundColor: colors.background }]}>
            {/* ===== مقبض السحب ===== */}
            <View style={styles.modalDragHeader}>
              <View style={styles.modalDragIndicator} />
            </View>

            <ScrollView style={styles.modalScroll} bounces={false} showsVerticalScrollIndicator={false}>
              {/* ===== معرض الصور ===== */}
              <View style={styles.carouselWrapper}>
                <ScrollView
                  horizontal
                  pagingEnabled
                  showsHorizontalScrollIndicator={false}
                  onScroll={(e) => {
                    const slide = Math.round(e.nativeEvent.contentOffset.x / e.nativeEvent.layoutMeasurement.width);
                    if (slide !== activeImageIndex) setActiveImageIndex(slide);
                  }}
                  scrollEventThrottle={16}
                >
                  {selectedCard.images.map((imgUri, idx) => (
                    <Image key={idx} source={{ uri: imgUri }} style={styles.carouselImage} />
                  ))}
                </ScrollView>

                {/* ===== النقاط الدائرية ===== */}
                <View style={styles.dotsContainer}>
                  {selectedCard.images.map((_, idx) => (
                    <View key={idx} style={[styles.dot, idx === activeImageIndex && styles.activeDot]} />
                  ))}
                </View>

                {/* ===== زر الإغلاق ===== */}
                <TouchableOpacity style={styles.closeModalButton} onPress={() => setModalVisible(false)}>
                  <Ionicons name="close" size={20} color="#FFFFFF" />
                </TouchableOpacity>
              </View>

              {/* ===== المعلومات ===== */}
              <View style={styles.modalDetailsContent}>
                <Text style={styles.modalSubtitle}>{selectedCard.subtitle}</Text>
                <Text style={[styles.modalTitle, { color: colors.text }]}>{selectedCard.title}</Text>
                <Text style={[styles.modalDescription, { color: colors.subText }]}>{selectedCard.description}</Text>

                <View style={styles.modalDivider} />

                <Text style={[styles.sectionHeading, { color: colors.text }]}>Overview & Amenities</Text>
                <Text style={[styles.sectionBodyText, { color: colors.subText }]}>
                  Enjoy exclusive privileges with instant booking confirmation, flexible cancellations, and premium VIP access provided directly through WE TRAVELERS. This property features a swimming pool, fitness center, and 24-hour room service.
                </Text>
              </View>
            </ScrollView>
          </View>
        )}
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },

  // ===== الشريط العلوي =====
  headerWrapper: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 100,
  },
  headerContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
  },
  headerLeftText: { flex: 1 },
  headerTitleText: {
    fontSize: 22,
    fontWeight: '800',
    fontFamily: 'System',
    letterSpacing: 0.2,
  },

  profileAvatarContainer: {
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'hidden',
  },
  profileIconWrapper: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: 'rgba(0, 100, 255, 0.08)',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 0.5,
    borderColor: 'rgba(0, 100, 255, 0.15)',
  },
  avatarImage: { width: 30, height: 30, borderRadius: 15 },

  scrollContainer: { paddingBottom: 20 },
  cardsWrapper: { paddingHorizontal: 16 },

  // ===== عناصر التحكم في الكروت =====
  hotelTabsRow: {
    flexDirection: 'row',
    backgroundColor: 'rgba(0,0,0,0.5)',
    borderRadius: 12,
    padding: 3,
  },
  hotelTabButton: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 9 },
  hotelTabActive: { backgroundColor: 'rgba(255,255,255,0.3)' },
  hotelTabText: { color: '#FFFFFF', fontSize: 11, fontWeight: '700' },

  timelineWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.15)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 10,
  },
  timelineLocation: { color: '#FFFFFF', fontWeight: '800', fontSize: 12 },
  timelineTrack: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingHorizontal: 8 },
  timelineDot: { width: 5, height: 5, borderRadius: 2.5, backgroundColor: '#007AFF' },
  timelineBar: { flex: 1, height: 1.5, backgroundColor: 'rgba(255,255,255,0.4)', marginHorizontal: 4 },

  // ===== النافذة المنبثقة =====
  modalContainer: { flex: 1 },
  modalDragHeader: {
    width: '100%',
    paddingVertical: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  modalDragIndicator: {
    width: 38,
    height: 5,
    borderRadius: 2.5,
    backgroundColor: 'rgba(150,150,150,0.4)',
  },
  modalScroll: { flex: 1 },
  carouselWrapper: {
    position: 'relative',
    height: 360,
    width: SCREEN_WIDTH,
  },
  carouselImage: {
    width: SCREEN_WIDTH,
    height: 360,
    resizeMode: 'cover',
  },
  dotsContainer: {
    position: 'absolute',
    bottom: 16,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  dot: {
    width: 7,
    height: 7,
    borderRadius: 3.5,
    backgroundColor: 'rgba(255,255,255,0.4)',
    marginHorizontal: 4,
  },
  activeDot: {
    backgroundColor: '#FFFFFF',
    width: 18,
  },
  closeModalButton: {
    position: 'absolute',
    top: 16,
    right: 16,
    backgroundColor: 'rgba(0,0,0,0.6)',
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalDetailsContent: {
    padding: 24,
  },
  modalSubtitle: {
    fontSize: 12,
    fontWeight: '700',
    color: '#007AFF',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
  },
  modalTitle: {
    fontSize: 28,
    fontWeight: '800',
    marginBottom: 10,
  },
  modalDescription: {
    fontSize: 15,
    lineHeight: 22,
  },
  modalDivider: {
    height: 1,
    backgroundColor: 'rgba(150,150,150,0.2)',
    marginVertical: 20,
  },
  sectionHeading: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 8,
  },
  sectionBodyText: {
    fontSize: 14,
    lineHeight: 22,
    marginBottom: 30,
  },
});