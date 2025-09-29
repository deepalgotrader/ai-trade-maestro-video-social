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
      "settings_placeholder": "Enter your custom response text..."
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
      "settings_placeholder": "Inserisci il tuo testo di risposta personalizzato..."
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