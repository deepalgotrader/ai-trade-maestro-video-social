import { useState } from 'react';
import type { FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { useSettings } from '../contexts/SettingsContext';
import { useChat } from '../contexts/ChatContext';
import { useConfig } from '../hooks/useConfig';
import { useAutoExpandTextarea } from '../hooks/useAutoExpandTextarea';
import MissileAnimation from '../components/MissileAnimation';

const Home = () => {
  const { t } = useTranslation();
  const { customResponse } = useSettings();
  const { messages, addMessage } = useChat();
  const { config } = useConfig();
  const [inputText, setInputText] = useState('');
  const [isThinking, setIsThinking] = useState(false);
  const [showMissile, setShowMissile] = useState(false);
  const [isGoingLive, setIsGoingLive] = useState(false);

  // Auto-expand textarea hook for better mobile UX
  const textareaRef = useAutoExpandTextarea(inputText, {
    maxHeightPx: 200,
    maxHeightVh: 30, // 30% of viewport on mobile
    minHeight: 56,
    enableMobileOptimization: true,
  });

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (!inputText.trim() || isThinking) return;

    // Add user message
    const userMessage = {
      id: Date.now().toString(),
      type: 'user' as const,
      content: inputText.trim(),
      timestamp: new Date()
    };

    addMessage(userMessage);
    setInputText('');
    setIsThinking(true);

    // Simulate AI thinking delay (2 seconds)
    setTimeout(() => {
      // Add AI response
      const aiMessage = {
        id: (Date.now() + 1).toString(),
        type: 'ai' as const,
        content: customResponse,
        timestamp: new Date()
      };
      addMessage(aiMessage);
      setIsThinking(false);
    }, 2000);
  };

  const handleGoLive = async () => {
    if (isGoingLive) return;

    setIsGoingLive(true);
    setShowMissile(true);

    // Add "Go Live" message
    const goLiveMessage = {
      id: Date.now().toString(),
      type: 'ai' as const,
      content: t('go_live_message'),
      timestamp: new Date()
    };
    addMessage(goLiveMessage);

    // Wait for missile animation to complete, then show success message
    // Configurable latency can be read from config.json
    setTimeout(() => {
      const successMessage = {
        id: (Date.now() + 1).toString(),
        type: 'ai' as const,
        content: t('trade_success_message'),
        timestamp: new Date()
      };
      addMessage(successMessage);
      setIsGoingLive(false);
    }, 4500); // 4.5 seconds total (missile animation + small delay)
  };

  const handleMissileComplete = () => {
    setShowMissile(false);
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex flex-col">
      {/* Header */}
      <div className="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700 py-3 sm:py-4">
        <div className="max-w-4xl mx-auto px-3 sm:px-4">
          <h1
            className="text-2xl sm:text-3xl font-bold"
            style={{ color: config?.colors.titleColor || '#0AD9E4' }}
          >
            {t('app_name')}
          </h1>
          <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400 mt-1">
            {t('welcome_description')}
          </p>
        </div>
      </div>

      {/* Messages Area */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-4xl mx-auto px-3 sm:px-4 py-4 sm:py-6">
          {messages.length === 0 ? (
            <div className="flex items-center justify-center h-full min-h-[400px]">
              <div className="text-center">
                <div className="w-16 h-16 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg className="w-8 h-8 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                </div>
                <p className="text-gray-500 dark:text-gray-400 text-lg">
                  {t('ai_response_placeholder')}
                </p>
                <p className="text-gray-400 dark:text-gray-500 text-sm mt-2">
                  {t('send_to_start')}
                </p>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              {messages.map((message) => (
                <div
                  key={message.id}
                  className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
                >
                  <div
                    className={`max-w-[85%] sm:max-w-[80%] rounded-xl px-3 sm:px-4 py-2.5 sm:py-3 ${
                      message.type === 'user'
                        ? 'bg-primary text-white'
                        : 'bg-white dark:bg-gray-800 text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700'
                    }`}
                  >
                    {message.type === 'ai' && (
                      <div className="flex items-center space-x-2 mb-2">
                        <div className="w-6 h-6 bg-primary rounded-full flex items-center justify-center flex-shrink-0">
                          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                          </svg>
                        </div>
                        <span className="text-xs font-medium text-gray-500 dark:text-gray-400">
                          AI Assistant
                        </span>
                      </div>
                    )}
                    <p className="whitespace-pre-wrap break-words">{message.content}</p>
                  </div>
                </div>
              ))}

              {/* Thinking Animation */}
              {isThinking && (
                <div className="flex justify-start">
                  <div className="max-w-[85%] sm:max-w-[80%] rounded-xl px-3 sm:px-4 py-2.5 sm:py-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700">
                    <div className="flex items-center space-x-2 mb-2">
                      <div className="w-6 h-6 bg-primary rounded-full flex items-center justify-center flex-shrink-0">
                        <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                        </svg>
                      </div>
                      <span className="text-xs font-medium text-gray-500 dark:text-gray-400">
                        AI Assistant
                      </span>
                    </div>
                    <div className="flex space-x-1">
                      <div className="w-2 h-2 bg-gray-400 dark:bg-gray-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
                      <div className="w-2 h-2 bg-gray-400 dark:bg-gray-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
                      <div className="w-2 h-2 bg-gray-400 dark:bg-gray-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Input Area - Fixed at bottom */}
      <div className="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 shadow-lg">
        <div className="max-w-4xl mx-auto px-3 sm:px-4 py-3 sm:py-4">
          <form onSubmit={handleSubmit} className="space-y-3">
            {/* Text Input */}
            <div className="w-full">
              <textarea
                ref={textareaRef}
                value={inputText}
                onChange={(e) => setInputText(e.target.value)}
                placeholder={t('enter_text')}
                rows={1}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handleSubmit(e);
                  }
                }}
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 transition-all duration-150 ease-in-out text-base"
                style={{
                  minHeight: '56px',
                  resize: 'none',
                  overflow: 'hidden'
                }}
                aria-label={t('enter_text')}
              />
            </div>

            {/* Buttons Row */}
            <div className="flex gap-2 sm:gap-3">
              <button
                type="submit"
                disabled={!inputText.trim() || isThinking}
                className="flex-1 px-4 sm:px-6 py-3.5 bg-primary hover:bg-opacity-90 disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold rounded-xl transition-all duration-200 flex items-center justify-center gap-2 shadow-lg hover:shadow-xl"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                </svg>
                <span className="text-base">{t('send')}</span>
              </button>
              <button
                type="button"
                onClick={handleGoLive}
                disabled={messages.length === 0 || isGoingLive}
                className="flex-1 px-4 sm:px-6 py-3.5 bg-gradient-to-r from-red-600 to-orange-600 hover:from-red-700 hover:to-orange-700 disabled:opacity-50 disabled:cursor-not-allowed text-white font-bold rounded-xl transition-all duration-200 flex items-center justify-center gap-2 shadow-lg hover:shadow-xl"
              >
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" />
                </svg>
                <span className="text-base">{t('go_live')}</span>
              </button>
            </div>
          </form>

          {/* Quick Actions - Below input */}
          {config?.ui.chatbot.quickActions && (
            <div className="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-3">
              {config.ui.chatbot.quickActions.map((action) => {
                const shortcutBorderColor = config?.colors.shortcutBorder || '#FFD300';
                const shortcutIconColor = config?.colors.shortcutIcon || '#FFD300';

                return (
                  <button
                    key={action.id}
                    onClick={() => setInputText(t(action.promptKey))}
                    className="group relative p-3 border-2 rounded-xl transition-all duration-200 text-left bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transform hover:scale-105 hover:shadow-lg"
                    style={{ borderColor: shortcutBorderColor }}
                  >
                    <div className="flex items-start space-x-3">
                      <div
                        className="flex-shrink-0 w-10 h-10 rounded-lg flex items-center justify-center text-xl transition-transform group-hover:scale-110"
                        style={{ color: shortcutIconColor }}
                      >
                        {action.icon}
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="font-semibold text-gray-900 dark:text-white text-sm mb-0.5">
                          {t(action.titleKey)}
                        </h4>
                        <p className="text-xs text-gray-600 dark:text-gray-400 line-clamp-2">
                          {t(action.descriptionKey)}
                        </p>
                      </div>
                    </div>
                    <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <svg className="w-4 h-4 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                      </svg>
                    </div>
                  </button>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Missile Animation */}
      <MissileAnimation
        isActive={showMissile}
        onComplete={handleMissileComplete}
      />
    </div>
  );
};

export default Home;
