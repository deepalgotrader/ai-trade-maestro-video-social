import React, { createContext, useContext, useState } from 'react';

interface SettingsContextType {
  customResponse: string;
  setCustomResponse: (response: string) => void;
}

const SettingsContext = createContext<SettingsContextType | undefined>(undefined);

export const SettingsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [customResponse, setCustomResponse] = useState<string>(() => {
    return localStorage.getItem('customResponse') || 'This is your custom response text!';
  });

  const updateCustomResponse = (response: string) => {
    setCustomResponse(response);
    localStorage.setItem('customResponse', response);
  };

  return (
    <SettingsContext.Provider value={{
      customResponse,
      setCustomResponse: updateCustomResponse
    }}>
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = () => {
  const context = useContext(SettingsContext);
  if (context === undefined) {
    throw new Error('useSettings must be used within a SettingsProvider');
  }
  return context;
};