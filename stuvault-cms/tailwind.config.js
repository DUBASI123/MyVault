/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        base: {
          950: '#05060A',
          900: '#0A0B10',
          800: '#12141C',
          700: '#1B1E29',
        },
        accent: {
          cyan: '#4FD1E8',
          blue: '#5B8CFF',
          deep: '#2E5EFF',
        },
      },
      fontFamily: {
        display: ['"Space Grotesk"', 'sans-serif'],
        body: ['"Inter"', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
      },
      backgroundImage: {
        'aurora': 'radial-gradient(circle at 15% 0%, rgba(79,209,232,0.16), transparent 45%), radial-gradient(circle at 85% 20%, rgba(91,140,255,0.14), transparent 40%), radial-gradient(circle at 50% 100%, rgba(46,94,255,0.10), transparent 50%)',
        'glass-gradient': 'linear-gradient(135deg, rgba(255,255,255,0.06), rgba(255,255,255,0.02))',
      },
      boxShadow: {
        glass: '0 8px 32px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.06)',
      },
    },
  },
  plugins: [],
}
