import { useEffect, useState } from 'react';

interface MissileAnimationProps {
  isActive: boolean;
  onComplete: () => void;
}

const MissileAnimation = ({ isActive, onComplete }: MissileAnimationProps) => {
  const [showTrail, setShowTrail] = useState(false);

  useEffect(() => {
    if (isActive) {
      setShowTrail(true);
      // Extended animation duration: 4 seconds for full sequence
      const timer = setTimeout(() => {
        setShowTrail(false);
        onComplete();
      }, 4000);

      return () => clearTimeout(timer);
    }
  }, [isActive, onComplete]);

  if (!isActive && !showTrail) return null;

  return (
    <div className="fixed inset-0 pointer-events-none z-50">
      {/* Missile */}
      <div
        className={`absolute bottom-4 left-1/2 transform -translate-x-1/2 ${
          isActive ? 'missile-trajectory' : ''
        }`}
      >
        {/* Missile Body */}
        <div className="relative">
          {/* Main Rocket */}
          <div className="w-16 h-32 bg-gradient-to-t from-gray-600 via-gray-400 to-gray-300 rounded-t-full relative shadow-2xl">
            {/* Rocket Tip */}
            <div className="absolute -top-4 left-1/2 transform -translate-x-1/2 w-8 h-12 bg-gradient-to-t from-red-500 to-yellow-400 rounded-full"></div>

            {/* Rocket Windows */}
            <div className="absolute top-6 left-1/2 transform -translate-x-1/2 w-6 h-6 bg-blue-400 rounded-full opacity-80"></div>
            <div className="absolute top-14 left-1/2 transform -translate-x-1/2 w-4 h-4 bg-blue-300 rounded-full opacity-70"></div>

            {/* Rocket Fins */}
            <div className="absolute -bottom-2 -left-2 w-6 h-8 bg-gray-500 transform rotate-12 shadow-lg"></div>
            <div className="absolute -bottom-2 -right-2 w-6 h-8 bg-gray-500 transform -rotate-12 shadow-lg"></div>
          </div>

          {/* Fire Trail */}
          <div className="absolute -bottom-4 left-1/2 transform -translate-x-1/2">
            {/* Main Flame */}
            <div className="w-12 h-16 bg-gradient-to-b from-red-500 via-orange-400 to-yellow-300 rounded-b-full flame-flicker opacity-90"></div>

            {/* Flame Particles */}
            <div className="absolute -bottom-2 left-2 w-4 h-8 bg-gradient-to-b from-orange-400 to-red-600 rounded-full animate-bounce opacity-70"></div>
            <div className="absolute -bottom-2 right-2 w-4 h-8 bg-gradient-to-b from-yellow-400 to-orange-500 rounded-full animate-bounce opacity-70" style={{ animationDelay: '0.1s' }}></div>

            {/* Smoke Trail */}
            <div className="absolute -bottom-8 left-1/2 transform -translate-x-1/2">
              <div className="w-8 h-12 bg-gray-400 rounded-full opacity-40 animate-ping"></div>
              <div className="absolute -bottom-4 w-12 h-8 bg-gray-300 rounded-full opacity-30 animate-pulse"></div>
            </div>
          </div>

          {/* Sparkles */}
          <div className="absolute inset-0">
            <div className="absolute top-1 -left-2 w-1 h-1 bg-yellow-300 rounded-full sparkle-effect" style={{ animationDelay: '0.2s' }}></div>
            <div className="absolute top-3 -right-3 w-1 h-1 bg-white rounded-full sparkle-effect" style={{ animationDelay: '0.4s' }}></div>
            <div className="absolute top-6 -left-1 w-1 h-1 bg-yellow-400 rounded-full sparkle-effect" style={{ animationDelay: '0.6s' }}></div>
            <div className="absolute top-8 -right-2 w-1 h-1 bg-orange-300 rounded-full sparkle-effect" style={{ animationDelay: '0.8s' }}></div>
          </div>
        </div>
      </div>

      {/* Trail Effect */}
      {showTrail && (
        <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2">
          <div className="w-1 h-screen bg-gradient-to-t from-orange-400 via-red-400 to-transparent opacity-30 animate-pulse"></div>
        </div>
      )}

      {/* Massive Explosion Effect */}
      {isActive && (
        <>
          {/* Main Explosion */}
          <div
            className="absolute top-8 left-1/2 transform -translate-x-1/2 opacity-0"
            style={{
              animationDelay: '1.3s',
              animationDuration: '0.6s',
              animationFillMode: 'forwards',
              animation: 'explosion-main 0.6s ease-out 1.3s forwards',
            }}
          >
            <div className="relative">
              {/* Central Explosion */}
              <div className="w-24 h-24 bg-gradient-to-r from-yellow-400 via-orange-500 to-red-500 rounded-full animate-ping"></div>
              <div className="absolute inset-0 w-24 h-24 bg-gradient-to-r from-red-500 via-orange-400 to-yellow-300 rounded-full animate-pulse"></div>

              {/* Explosion Rings */}
              <div className="absolute -inset-4 w-32 h-32 border-4 border-orange-400 rounded-full animate-ping opacity-70"></div>
              <div className="absolute -inset-8 w-40 h-40 border-2 border-red-400 rounded-full animate-ping opacity-50" style={{ animationDelay: '0.1s' }}></div>
            </div>
          </div>

          {/* Falling Bombs */}
          <div
            className="absolute top-16 left-1/2 transform -translate-x-1/2"
            style={{
              animationDelay: '1.5s',
              animationFillMode: 'forwards',
            }}
          >
            {/* Bomb 1 */}
            <div
              className="absolute w-3 h-6 bg-gradient-to-b from-gray-700 to-gray-900 rounded-full shadow-lg"
              style={{
                left: '-60px',
                animation: 'bomb-fall 1s ease-in 1.5s forwards',
              }}
            >
              <div className="absolute -top-1 left-1/2 transform -translate-x-1/2 w-1 h-2 bg-orange-400 rounded-full"></div>
            </div>

            {/* Bomb 2 */}
            <div
              className="absolute w-3 h-6 bg-gradient-to-b from-gray-700 to-gray-900 rounded-full shadow-lg"
              style={{
                left: '-20px',
                animation: 'bomb-fall 1.2s ease-in 1.6s forwards',
              }}
            >
              <div className="absolute -top-1 left-1/2 transform -translate-x-1/2 w-1 h-2 bg-orange-400 rounded-full"></div>
            </div>

            {/* Bomb 3 */}
            <div
              className="absolute w-3 h-6 bg-gradient-to-b from-gray-700 to-gray-900 rounded-full shadow-lg"
              style={{
                left: '20px',
                animation: 'bomb-fall 1.1s ease-in 1.7s forwards',
              }}
            >
              <div className="absolute -top-1 left-1/2 transform -translate-x-1/2 w-1 h-2 bg-orange-400 rounded-full"></div>
            </div>

            {/* Bomb 4 */}
            <div
              className="absolute w-3 h-6 bg-gradient-to-b from-gray-700 to-gray-900 rounded-full shadow-lg"
              style={{
                left: '60px',
                animation: 'bomb-fall 0.9s ease-in 1.8s forwards',
              }}
            >
              <div className="absolute -top-1 left-1/2 transform -translate-x-1/2 w-1 h-2 bg-orange-400 rounded-full"></div>
            </div>
          </div>

          {/* Secondary Explosions */}
          <div
            style={{
              animationDelay: '2.5s',
              animationFillMode: 'forwards',
            }}
          >
            {/* Small Explosion 1 */}
            <div
              className="absolute opacity-0"
              style={{
                top: '70vh',
                left: '30%',
                animation: 'small-explosion 0.4s ease-out 2.5s forwards',
              }}
            >
              <div className="w-8 h-8 bg-gradient-to-r from-orange-500 to-red-500 rounded-full animate-ping"></div>
            </div>

            {/* Small Explosion 2 */}
            <div
              className="absolute opacity-0"
              style={{
                top: '75vh',
                left: '45%',
                animation: 'small-explosion 0.4s ease-out 2.7s forwards',
              }}
            >
              <div className="w-6 h-6 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-full animate-ping"></div>
            </div>

            {/* Small Explosion 3 */}
            <div
              className="absolute opacity-0"
              style={{
                top: '80vh',
                left: '60%',
                animation: 'small-explosion 0.4s ease-out 2.9s forwards',
              }}
            >
              <div className="w-10 h-10 bg-gradient-to-r from-red-500 to-yellow-500 rounded-full animate-ping"></div>
            </div>

            {/* Small Explosion 4 */}
            <div
              className="absolute opacity-0"
              style={{
                top: '85vh',
                left: '70%',
                animation: 'small-explosion 0.4s ease-out 3.1s forwards',
              }}
            >
              <div className="w-7 h-7 bg-gradient-to-r from-orange-500 to-red-500 rounded-full animate-ping"></div>
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default MissileAnimation;