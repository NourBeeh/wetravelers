// src/components/AppStoreCard.js
import React from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');

// ============================================
// 1. المقاسات الثابتة (تم تعديل العرض ليتوافق مع Today)
// ============================================
const CARD_WIDTH = width - 40;     // هامش 20pt من كل جانب (مثل Today)
const CARD_HEIGHT = 440;           // ارتفاع ثابت
const CORNER_RADIUS = 20;
const CARD_MARGIN = 8;

// ============================================
// 2. الألوان (بني داكن)
// ============================================
const COLORS = [
  '#3D2B1F', // RGB: 61, 43, 31
  '#2C1810', // RGB: 44, 24, 16
  '#1A1108', // RGB: 26, 17, 8
  '#4A3728', // RGB: 74, 55, 40
  '#2F1B0E', // RGB: 47, 27, 14
];

// دالة لتحويل اللون السداسي إلى قيم RGB
const hexToRgb = (hex) => {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : { r: 61, g: 43, b: 31 };
};

export default function AppStoreCard({
  title,
  subtitle,
  description,
  image,
  onPress,
  index = 0,
  tagText = 'عرض خاص',
}) {
  const backgroundColor = COLORS[index % COLORS.length];
  const rgb = hexToRgb(backgroundColor);

  return (
    <TouchableOpacity
      style={[styles.card, { backgroundColor }]}
      onPress={onPress}
      activeOpacity={0.95}
    >
      {/* ===== الخلفية البنية للكارت ===== */}
      <View style={[styles.cardBackground, { backgroundColor }]} />

      {/* ===== الصورة مع هوامش متساوية ===== */}
      <View style={styles.imageContainer}>
        <Image source={image} style={styles.image} resizeMode="cover" />

        {/* ===== التدرج الشفاف باستخدام rgba صريحة ===== */}
        <LinearGradient
          colors={[
            `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0)`,   // 0%: شفاف تماماً
            `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0)`,   // 50%: شفاف تماماً
            `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.8)`, // 70%: شبه معتم
            `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 1)`,   // 100%: معتم تماماً
          ]}
          locations={[0, 0.5, 0.7, 1]}
          start={{ x: 0, y: 0 }}
          end={{ x: 0, y: 1 }}
          style={styles.gradientOverlay}
        />
      </View>

      {/* ===== المستطيل الشمالي العلوي (Tag) ===== */}
      <View style={[styles.tagContainer, { backgroundColor }]}>
        <Text style={styles.tagText}>{tagText}</Text>
      </View>

      {/* ===== المحتوى النصي ===== */}
      <View style={styles.contentContainer}>
        <Text style={[styles.subtitleText, { color: 'rgba(255,255,255,0.7)' }]}>
          {subtitle || 'وجهة مميزة'}
        </Text>

        <Text style={[styles.titleText, { color: '#FFFFFF' }]} numberOfLines={2}>
          {title}
        </Text>

        <Text style={[styles.descriptionText, { color: 'rgba(255,255,255,0.85)' }]} numberOfLines={2}>
          {description || 'اكتشف أفضل العروض والوجهات السياحية'}
        </Text>
      </View>

      {/* ===== زر GET في أسفل اليمين ===== */}
      <View style={styles.getButtonWrapper}>
        <TouchableOpacity style={styles.getButton} onPress={onPress}>
          <Text style={styles.getButtonText}>GET</Text>
        </TouchableOpacity>
        <Text style={styles.inAppText}>مشتريات داخلية</Text>
      </View>
    </TouchableOpacity>
  );
}

// ============================================
// 5. الأنماط (Styles)
// ============================================
const styles = StyleSheet.create({
  card: {
    width: CARD_WIDTH,
    height: CARD_HEIGHT,
    borderRadius: CORNER_RADIUS,
    overflow: 'hidden',
    marginBottom: 20,
    alignSelf: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 8,
    position: 'relative',
  },
  cardBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  imageContainer: {
    position: 'absolute',
    top: CARD_MARGIN,
    left: CARD_MARGIN,
    right: CARD_MARGIN,
    bottom: CARD_MARGIN,
    borderRadius: 16,
    overflow: 'hidden',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  gradientOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  tagContainer: {
    position: 'absolute',
    top: 20,
    left: 20,
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 12,
    zIndex: 3,
    borderWidth: 0.5,
    borderColor: 'rgba(255,255,255,0.1)',
  },
  tagText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  contentContainer: {
    position: 'absolute',
    bottom: 70,
    left: 24,
    right: 24,
    zIndex: 2,
  },
  subtitleText: {
    fontSize: 12,
    fontWeight: '500',
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  titleText: {
    fontSize: 26,
    fontWeight: '700',
    marginBottom: 6,
    lineHeight: 30,
    color: '#FFFFFF',
  },
  descriptionText: {
    fontSize: 15,
    fontWeight: '400',
    lineHeight: 20,
    opacity: 0.9,
  },
  getButtonWrapper: {
    position: 'absolute',
    bottom: 20,
    right: 20,
    zIndex: 3,
    alignItems: 'center',
  },
  getButton: {
    backgroundColor: '#FFFFFF',
    width: 74,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  getButtonText: {
    color: '#007AFF',
    fontSize: 14,
    fontWeight: '600',
  },
  inAppText: {
    color: 'rgba(255,255,255,0.4)',
    fontSize: 9,
    marginTop: 2,
    textAlign: 'center',
  },
});