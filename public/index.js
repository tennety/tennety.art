import loader from "/little-loader.js";
/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    loader()
    window._lload("https://www.googletagmanager.com/gtag/js?id=G-HL4W824LYR", () => {
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
    
      gtag('config', 'G-HL4W824LYR');
    })
    window._lload('https://storage.ko-fi.com/cdn/scripts/overlay-widget.js', () => {
      kofiWidgetOverlay.draw('tennetyart', {
        'type': 'floating-chat',
        'floating-chat.donateButton.text': 'Support me',
        'floating-chat.donateButton.background-color': '#363c46',
        'floating-chat.donateButton.text-color': '#f7fafc'
      });
    })

    const app = await elmLoaded;
  },
  flags: function () {
    const colorSchemePreference = ['light', 'dark', 'no-preference'].find(pref => window.matchMedia(`(prefers-color-scheme: ${pref})`).matches)
    return colorSchemePreference
  },
};
