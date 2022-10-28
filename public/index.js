import loader from "/little-loader.js";
/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    loader()
    window._lload("https://www.googletagmanager.com/gtag/js?id=UA-157882374-1", () => {
      console.log("pups")
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());

      gtag('config', 'UA-157882374-1');
    })

    const app = await elmLoaded;
    console.log("App loaded", app);
  },
  flags: function () {
    const colorSchemePreference = ['light', 'dark', 'no-preference'].find(pref => window.matchMedia(`(prefers-color-scheme: ${pref})`).matches)
    return colorSchemePreference
  },
};
