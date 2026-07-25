// src/screens/AIScreen.js
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  useColorScheme,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { Ionicons } from '@expo/vector-icons';

export default function AIScreen() {
  const { t } = useTranslation();
  const scheme = useColorScheme();
  const isDark = scheme === 'dark';

  const [messages, setMessages] = useState([
    { id: 1, text: t('ai.welcome'), sender: 'ai' },
  ]);
  const [inputText, setInputText] = useState('');

  const colors = {
    background: isDark ? '#1C1C1E' : '#F2F2F7',
    card: isDark ? '#2C2C2E' : '#FFFFFF',
    text: isDark ? '#F2F2F7' : '#1C1C1E',
    subText: isDark ? '#98989E' : '#8E8E93',
    border: isDark ? 'rgba(60,60,67,0.36)' : 'rgba(60,60,67,0.08)',
    inputBg: isDark ? '#3A3A3C' : '#F2F2F7',
    aiBubble: isDark ? '#3A3A3C' : '#E9E9EB',
    userBubble: isDark ? '#0A84FF' : '#007AFF',
  };

  const sendMessage = () => {
    if (inputText.trim() === '') return;

    const userMessage = { id: messages.length + 1, text: inputText, sender: 'user' };
    setMessages([...messages, userMessage]);
    setInputText('');

    setTimeout(() => {
      const aiResponse = {
        id: messages.length + 2,
        text: t('ai.welcome'),
        sender: 'ai',
      };
      setMessages((prev) => [...prev, aiResponse]);
    }, 1000);
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}
      >
        <View style={[styles.header, { backgroundColor: colors.card, borderBottomColor: colors.border }]}>
          <Text style={[styles.headerTitle, { color: colors.text }]}>{t('ai.title')}</Text>
          <Text style={[styles.headerSubtitle, { color: colors.subText }]}>{t('ai.subtitle')}</Text>
        </View>

        <ScrollView
          style={styles.chatContainer}
          contentContainerStyle={styles.chatContent}
          showsVerticalScrollIndicator={false}
        >
          {messages.map((msg) => (
            <View
              key={msg.id}
              style={[
                styles.messageBubble,
                msg.sender === 'user'
                  ? [styles.userBubble, { backgroundColor: colors.userBubble }]
                  : [styles.aiBubble, { backgroundColor: colors.aiBubble }],
              ]}
            >
              <Text
                style={[
                  styles.messageText,
                  msg.sender === 'user' ? styles.userText : [styles.aiText, { color: colors.text }],
                ]}
              >
                {msg.text}
              </Text>
            </View>
          ))}
        </ScrollView>

        <View style={[styles.inputContainer, { backgroundColor: colors.card, borderTopColor: colors.border }]}>
          <TextInput
            style={[styles.input, { backgroundColor: colors.inputBg, color: colors.text }]}
            placeholder={t('ai.placeholder')}
            placeholderTextColor={colors.subText}
            value={inputText}
            onChangeText={setInputText}
            multiline
            maxLength={200}
          />
          <TouchableOpacity
            style={[styles.sendButton, !inputText.trim() && styles.sendButtonDisabled]}
            onPress={sendMessage}
            disabled={!inputText.trim()}
          >
            <Ionicons
              name="send"
              size={22}
              color={inputText.trim() ? '#FFFFFF' : '#C7C7CC'}
            />
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  keyboardView: { flex: 1 },
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 16,
    borderBottomWidth: 0.5,
  },
  headerTitle: { fontSize: 22, fontWeight: '700' },
  headerSubtitle: { fontSize: 14, marginTop: 2 },
  chatContainer: { flex: 1, paddingHorizontal: 16 },
  chatContent: { paddingVertical: 16 },
  messageBubble: { maxWidth: '80%', padding: 14, borderRadius: 20, marginBottom: 10 },
  aiBubble: { alignSelf: 'flex-start', borderBottomLeftRadius: 4 },
  userBubble: { alignSelf: 'flex-end', borderBottomRightRadius: 4 },
  messageText: { fontSize: 16, lineHeight: 22 },
  aiText: { fontWeight: '400' },
  userText: { color: '#FFFFFF' },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderTopWidth: 0.5,
  },
  input: { flex: 1, borderRadius: 20, paddingHorizontal: 16, paddingVertical: 10, maxHeight: 100, fontSize: 16 },
  sendButton: { width: 44, height: 44, borderRadius: 22, backgroundColor: '#007AFF', justifyContent: 'center', alignItems: 'center', marginLeft: 8 },
  sendButtonDisabled: { backgroundColor: '#E9E9EB' },
});