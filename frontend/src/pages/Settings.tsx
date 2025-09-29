import { useState, FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { useSettings } from '../contexts/SettingsContext';

const Settings = () => {
  const { t } = useTranslation();
  const { customResponse, setCustomResponse } = useSettings();
  const [inputValue, setInputValue] = useState(customResponse);
  const [isSaved, setIsSaved] = useState(false);

  const handleSave = (e: FormEvent) => {
    e.preventDefault();
    setCustomResponse(inputValue);
    setIsSaved(true);

    setTimeout(() => {
      setIsSaved(false);
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">
            {t('settings')}
          </h2>

          <form onSubmit={handleSave} className="space-y-4">
            <div>
              <label htmlFor="customResponse" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Custom Response Text
              </label>
              <textarea
                id="customResponse"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                placeholder={t('settings_placeholder')}
                rows={4}
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 resize-vertical"
              />
            </div>

            <div className="flex items-center justify-between">
              <button
                type="submit"
                className="px-6 py-3 bg-primary hover:bg-opacity-90 text-white font-medium rounded-lg transition-all duration-200"
              >
                Save Settings
              </button>

              {isSaved && (
                <div className="flex items-center space-x-2 text-green-600 dark:text-green-400">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                  <span className="text-sm font-medium">Settings saved!</span>
                </div>
              )}
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Settings;