import { useEffect, useRef, useState } from 'react';

interface UseAutoExpandTextareaOptions {
  maxHeightPx?: number;
  maxHeightVh?: number; // Percentage of viewport height
  minHeight?: number;
  enableMobileOptimization?: boolean;
}

export const useAutoExpandTextarea = (
  value: string,
  options: UseAutoExpandTextareaOptions = {}
) => {
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const [isMobile, setIsMobile] = useState(false);

  const {
    maxHeightPx = 200,
    maxHeightVh = 30, // 30% of viewport on mobile
    minHeight = 56,
    enableMobileOptimization = true
  } = options;

  // Detect mobile on mount
  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
    };
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  useEffect(() => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    // Calculate max height based on device
    let calculatedMaxHeight = maxHeightPx;
    if (enableMobileOptimization && isMobile) {
      const viewportHeight = window.visualViewport?.height || window.innerHeight;
      calculatedMaxHeight = Math.min(
        maxHeightPx,
        (viewportHeight * maxHeightVh) / 100
      );
    }

    // Reset height to get accurate scrollHeight
    textarea.style.height = `${minHeight}px`;

    // Calculate new height
    const scrollHeight = textarea.scrollHeight;
    const newHeight = Math.min(
      Math.max(scrollHeight, minHeight),
      calculatedMaxHeight
    );

    // Apply new height with smooth transition
    textarea.style.height = `${newHeight}px`;

    // Manage overflow
    if (scrollHeight > calculatedMaxHeight) {
      textarea.style.overflowY = 'auto';
    } else {
      textarea.style.overflowY = 'hidden';
    }
  }, [value, maxHeightPx, maxHeightVh, minHeight, enableMobileOptimization, isMobile]);

  return textareaRef;
};
