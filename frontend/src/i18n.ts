import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

const resources = {
  en: {
    translation: {
      "app_name": "AI TradeMaestro",
      "home": "Home",
      "settings": "Settings",
      "enter_text": "Enter your message...",
      "send": "Send",
      "light": "Light",
      "dark": "Dark",
      "language": "Language",
      "settings_placeholder": "Enter your custom response text...",

      // Home page
      "welcome_title": "Welcome to",
      "welcome_description": "Your AI-powered trading assistant. Enter your message below and get intelligent responses.",
      "send_message": "Send Message",
      "your_message": "Your Message",
      "characters": "characters",
      "sending": "Sending...",
      "ai_response": "AI Response",
      "ai_response_placeholder": "AI response will appear here",
      "send_to_start": "Send a message to get started",
      "go_live": "Go Live",

      // Quick actions
      "quick_actions": "Quick Actions",
      "market_trends": "Market Trends",
      "market_trends_desc": "Ask about current trends",
      "market_trends_question": "What are the current market trends?",
      "portfolio_analysis": "Portfolio Analysis",
      "portfolio_analysis_desc": "Get portfolio insights",
      "portfolio_analysis_question": "Help me analyze my portfolio",
      "strategies": "Strategies",
      "strategies_desc": "Learn trading strategies",
      "strategies_question": "What trading strategies do you recommend?",

      // Settings page
      "custom_response_label": "Custom Response Text",
      "save_settings": "Save Settings",
      "settings_saved": "Settings saved!"
    }
  },
  it: {
    translation: {
      "app_name": "AI TradeMaestro",
      "home": "Home",
      "settings": "Impostazioni",
      "enter_text": "Inserisci il tuo messaggio...",
      "send": "Invia",
      "light": "Chiaro",
      "dark": "Scuro",
      "language": "Lingua",
      "settings_placeholder": "Inserisci il tuo testo di risposta personalizzato...",

      // Home page
      "welcome_title": "Benvenuto su",
      "welcome_description": "Il tuo assistente di trading basato su AI. Inserisci il tuo messaggio qui sotto e ricevi risposte intelligenti.",
      "send_message": "Invia Messaggio",
      "your_message": "Il Tuo Messaggio",
      "characters": "caratteri",
      "sending": "Invio in corso...",
      "ai_response": "Risposta AI",
      "ai_response_placeholder": "La risposta dell'AI apparirà qui",
      "send_to_start": "Invia un messaggio per iniziare",
      "go_live": "Metti Live",

      // Quick actions
      "quick_actions": "Azioni Rapide",
      "market_trends": "Tendenze di Mercato",
      "market_trends_desc": "Chiedi sulle tendenze attuali",
      "market_trends_question": "Quali sono le tendenze di mercato attuali?",
      "portfolio_analysis": "Analisi Portfolio",
      "portfolio_analysis_desc": "Ottieni informazioni sul portfolio",
      "portfolio_analysis_question": "Aiutami ad analizzare il mio portfolio",
      "strategies": "Strategie",
      "strategies_desc": "Impara le strategie di trading",
      "strategies_question": "Quali strategie di trading mi consigli?",

      // Settings page
      "custom_response_label": "Testo Risposta Personalizzata",
      "save_settings": "Salva Impostazioni",
      "settings_saved": "Impostazioni salvate!"
    }
  }
};

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: 'en',
    interpolation: {
      escapeValue: false,
    }
  });

export default i18n;