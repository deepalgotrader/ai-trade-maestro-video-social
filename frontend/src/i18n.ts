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
      "welcome_description": "Your AI-powered trading assistant.",
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
      "settings_saved": "Settings saved!",

      // Chatbot messages
      "go_live_message": "🚀 Go Live initiated! Preparing to execute trade...",
      "trade_success_message": "✅ The trade has been executed successfully!",

      // Quick Actions - Crypto Trading
      "quick_action_btc_title": "Bitcoin Analysis",
      "quick_action_btc_desc": "Real-time BTC market analysis",
      "quick_action_btc_prompt": "Provide me with a comprehensive Bitcoin (BTC) market analysis including: current price action, key support and resistance levels, dominant market sentiment (bullish/bearish/neutral), important technical indicators (RSI, MACD, moving averages), on-chain metrics analysis, major news or events impacting the price, and your recommendation on whether this is a good entry point for long or short positions. Also include the best timeframe for this trade (scalping, day trading, or swing trading).",
      "quick_action_altcoin_title": "Altcoin Opportunities",
      "quick_action_altcoin_desc": "Discover high-potential altcoins",
      "quick_action_altcoin_prompt": "Identify the top 5 altcoin trading opportunities right now based on: strong technical setups (breakouts, bullish patterns), fundamental catalysts (upcoming events, partnerships, technology upgrades), volume analysis and liquidity, market cap potential for growth, correlation with Bitcoin and Ethereum movements. For each altcoin provide: ticker symbol, current price, potential entry zones, target profit levels (TP1, TP2, TP3), stop-loss recommendations, expected risk/reward ratio, and timeframe for the trade. Focus on coins with realistic 2x-5x potential in the short to medium term.",
      "quick_action_risk_title": "Risk Management",
      "quick_action_risk_desc": "Optimize your trading safety",
      "quick_action_risk_prompt": "Create a comprehensive risk management strategy for my crypto trading portfolio including: optimal position sizing based on portfolio value (recommend % per trade), stop-loss placement strategies (ATR-based, support/resistance levels, percentage-based), take-profit strategies and trailing stop recommendations, portfolio diversification guidelines (BTC vs altcoins allocation), leverage usage recommendations and warnings, how to handle volatile market conditions and black swan events, psychological tips for avoiding FOMO and panic selling, and daily/weekly risk limits to protect capital. Assume I'm trading with moderate risk tolerance and want to preserve capital while achieving steady growth."
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
      "welcome_description": "Il tuo assistente di trading basato su AI.",
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
      "settings_saved": "Impostazioni salvate!",

      // Chatbot messages
      "go_live_message": "🚀 Go Live avviato! Preparazione esecuzione trade...",
      "trade_success_message": "✅ Il trade è stato eseguito con successo!",

      // Quick Actions - Crypto Trading
      "quick_action_btc_title": "Analisi Bitcoin",
      "quick_action_btc_desc": "Analisi di mercato BTC in tempo reale",
      "quick_action_btc_prompt": "Forniscimi un'analisi completa del mercato Bitcoin (BTC) includendo: azione di prezzo corrente, livelli chiave di supporto e resistenza, sentiment dominante del mercato (rialzista/ribassista/neutrale), indicatori tecnici importanti (RSI, MACD, medie mobili), analisi delle metriche on-chain, notizie o eventi principali che impattano il prezzo, e la tua raccomandazione se questo è un buon punto d'ingresso per posizioni long o short. Includi anche il miglior timeframe per questo trade (scalping, day trading o swing trading).",
      "quick_action_altcoin_title": "Opportunità Altcoin",
      "quick_action_altcoin_desc": "Scopri altcoin ad alto potenziale",
      "quick_action_altcoin_prompt": "Identifica le top 5 opportunità di trading altcoin in questo momento basandoti su: setup tecnici forti (breakout, pattern rialzisti), catalizzatori fondamentali (eventi imminenti, partnership, aggiornamenti tecnologici), analisi del volume e liquidità, potenziale di crescita della market cap, correlazione con i movimenti di Bitcoin ed Ethereum. Per ogni altcoin fornisci: simbolo ticker, prezzo corrente, zone di entrata potenziali, livelli target di profitto (TP1, TP2, TP3), raccomandazioni stop-loss, rapporto rischio/rendimento atteso, e timeframe per il trade. Concentrati su coin con realistico potenziale 2x-5x nel breve-medio termine.",
      "quick_action_risk_title": "Gestione del Rischio",
      "quick_action_risk_desc": "Ottimizza la sicurezza del trading",
      "quick_action_risk_prompt": "Crea una strategia completa di gestione del rischio per il mio portfolio di trading crypto includendo: dimensionamento ottimale delle posizioni basato sul valore del portfolio (raccomanda % per trade), strategie di posizionamento stop-loss (basate su ATR, livelli supporto/resistenza, percentuali), strategie take-profit e raccomandazioni trailing stop, linee guida di diversificazione del portfolio (allocazione BTC vs altcoin), raccomandazioni sull'uso della leva finanziaria e avvertenze, come gestire condizioni di mercato volatili ed eventi cigno nero, consigli psicologici per evitare FOMO e vendite nel panico, e limiti di rischio giornalieri/settimanali per proteggere il capitale. Assumo che stia tradando con tolleranza al rischio moderata e voglia preservare il capitale ottenendo una crescita costante."
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