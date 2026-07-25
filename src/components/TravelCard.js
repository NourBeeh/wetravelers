// src/components/AppStoreCard.js
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  Platform,
} from 'react-native';
import { getColors } from 'react-native-image-colors';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width - 32;

export default function AppStoreCard({ title, subtitle, image, onPress }) {
  const [dominantColor, setDominantColor] = useState('#007AFF');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const extractColors = async () => {
      try {
        const colors = await getColors(image.uri, {
          fallback: '#007AFF',
          cache: true,
        });
        const mainColor = colors.platform === 'android'
          ? colors.dominant
          : colors.primary || colors.dominant;
        setDominantColor(mainColor || '#007AFF');
      } catch (error) {
        console.warn('Color extraction failed:', error);
        setDominantColor('#007AFF');
      } finally {
        setIsLoading(false);
      }
    };
    extractColors();
  }, [image]);

  return (
    <TouchableOpacity
      style={[styles.card, { backgroundColor: dominantColor }]}
      onPress={onPress}
      activeOpacity={0.9}
    >
      <View style={[styles.backgroundGradient, { backgroundColor: dominantColor }]} />

      <View style={styles.content}>
        <View style={styles.textContainer}>
          <Text style={styles.category}>عرض خاص</Text>
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.subtitle}>{subtitle}</Text>
        </View>

        <Image
          source={image}
          style={styles.image}
          resizeMode="cover"
          blurRadius={isLoading ? 10 : 0}
        />

        <TouchableOpacity style={styles.actionButton} onPress={onPress}>
          <Text style={styles.actionButtonText}>احجز الآن</Text>
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    width: CARD_WIDTH,
    borderRadius: 24,
    overflow: 'hidden',
    marginBottom: 20,
    alignSelf: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 12,
    elevation: 8,
    minHeight: 340,
  },
  backgroundGradient: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    opacity: 0.95,
  },
  content: {
    padding: 20,
    flex: 1,
  },
  textContainer: {
    marginBottom: 16,
    zIndex: 2,
  },
  category: {
    fontSize: 12,
    fontWeight: '600',
    color: 'rgba(255,255,255,0.7)',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 15,
    color: 'rgba(255,255,255,0.85)',
    fontWeight: '400',
  },
  image: {
    width: CARD_WIDTH - 40,
    height: 180,
    borderRadius: 16,
    position: 'absolute',
    bottom: 0,
    right: 0,
    opacity: 0.6,
    zIndex: 1,
  },
  actionButton: {
    position: 'absolute',
    bottom: 20,
    right: 20,
    backgroundColor: 'rgba(255,255,255,0.25)',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 25,
    borderWidth: 0.5,
    borderColor: 'rgba(255,255,255,0.3)',
    zIndex: 3,
    ...Platform.select({
      ios: {
        backgroundColor: 'rgba(255,255,255,0.2)',
      },
      android: {
        elevation: 2,
      },
    }),
  },
  actionButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
});