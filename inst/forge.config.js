module.exports = {
  packagerConfig: {
    icon: './shiny/assets/icon/icon'
  },
  rebuildConfig: {},
  makers: [
    {
      name: '@electron-forge/maker-zip'
    }
  ],
};
