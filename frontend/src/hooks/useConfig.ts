import { useState, useEffect } from 'react';

interface QuickAction {
  id: string;
  icon: string;
  titleKey: string;
  descriptionKey: string;
  promptKey: string;
  color: string;
}

interface Config {
  ui: {
    chatbot: {
      thinkingDelay: number;
      goLiveLatency: number;
      quickActions: QuickAction[];
    };
  };
}

export const useConfig = () => {
  const [config, setConfig] = useState<Config | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/config.json')
      .then(res => res.json())
      .then(data => {
        setConfig(data);
        setLoading(false);
      })
      .catch(error => {
        console.error('Error loading config:', error);
        setLoading(false);
      });
  }, []);

  return { config, loading };
};
