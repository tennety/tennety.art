/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    console.log("App loaded", app);
  },
  flags: function () {
    const colorSchemePreference = ['light', 'dark', 'no-preference'].find(pref => window.matchMedia(`(prefers-color-scheme: ${pref})`).matches)
    return colorSchemePreference
  },
};
