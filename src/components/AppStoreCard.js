// src/components/AppStoreCard.js
import React, { useRef } from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  Animated,
  Pressable,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width - 32;
const CORNER_RADIUS = 24;

export default function AppStoreCard({
  title = '',
  subtitle = '',
  description = '',
  image,
  tag = '',
  buttonText = 'BOOK',
  onPress,
  onLongPress,
  backgroundColor = '#1C2431',
  extraControls,
  extraContent,
}) {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = () => {
    Animated.spring(scaleAnim, {
      toValue: 0.96,
      useNativeDriver: true,
      speed: 20,
      bounciness: 6,
    }).start();
  };

  const handlePressOut = () => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      useNativeDriver: true,
      speed: 20,
      bounciness: 6,
    }).start();
  };

  return (
    <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
      <Pressable
        style={[styles.card, { backgroundColor }]}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        onPress={onPress}
        onLongPress={onLongPress}
        delayLongPress={300}
      >
        <View style={styles.imageWrapper}>
          <Image
            source={typeof image === 'string' ? { uri: image } : image}
            style={styles.image}
            resizeMode="cover"
          />
          <LinearGradient
            colors={['rgba(0,0,0,0.25)', 'transparent', backgroundColor]}
            locations={[0, 0.45, 1]}
            style={styles.gradientOverlay}
          />
          {tag ? (
            <View style={styles.tagContainer}>
              <Text style={styles.tagText}>{tag}</Text>
            </View>
          ) : null}
          {extraControls ? (
            <View style={styles.extraControlsContainer}>{extraControls}</View>
          ) : null}
        </View>

        <View style={[styles.bottomContent, { backgroundColor }]}>
          {subtitle ? <Text style={styles.subtitleText}>{subtitle}</Text> : null}
          {title ? <Text style={styles.titleText} numberOfLines={2}>{title}</Text> : null}
          {description ? <Text style={styles.descriptionText} numberOfLines={2}>{description}</Text> : null}
          {extraContent ? <View style={styles.extraContentWrapper}>{extraContent}</View> : null}

          <View style={styles.buttonRow}>
            <TouchableOpacity style={styles.actionButton} onPress={onPress} activeOpacity={0.8}>
              <Text style={styles.actionButtonText}>{buttonText}</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Pressable>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  card: {
    width: CARD_WIDTH,
    borderRadius: CORNER_RADIUS,
    overflow: 'hidden',
    marginBottom: 20,
    alignSelf: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.3,
    shadowRadius: 18,
    elevation: 12,
    // ✅ إزالة borderWidth و borderColor
  },
  imageWrapper: {
    width: '100%',
    height: 250,
    position: 'relative',
    overflow: 'hidden',
  },
  image: { width: '100%', height: '100%' },
  gradientOverlay: { ...StyleSheet.absoluteFillObject },
  tagContainer: {
    position: 'absolute',
    top: 14,
    left: 14,
    backgroundColor: 'rgba(0,0,0,0.55)',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 8,
    borderWidth: 0.5,
    borderColor: 'rgba(255,255,255,0.25)',
  },
  tagText: {
    color: '#FFFFFF',
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },
  extraControlsContainer: {
    position: 'absolute',
    top: 14,
    right: 14,
    zIndex: 4,
  },
  bottomContent: {
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255,255,255,0.08)',
  },
  subtitleText: {
    fontSize: 14,
    fontWeight: '700',
    color: 'rgba(255,255,255,0.7)',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  titleText: {
    fontSize: 24,
    fontWeight: '800',
    lineHeight: 30,
    color: '#FFFFFF',
    marginBottom: 4,
  },
  descriptionText: {
    fontSize: 15,
    fontWeight: '400',
    color: 'rgba(255,255,255,0.8)',
    lineHeight: 20,
    marginBottom: 10,
  },
  extraContentWrapper: { marginTop: 6 },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    marginTop: 6,
  },
  actionButton: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 24,
    paddingVertical: 10,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  actionButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
  },
});