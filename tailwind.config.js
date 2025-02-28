module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/components/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
  ],
  daisyui: {
    themes: [
      {
        mytheme: {
          primary: "#00008B",
          "primary-content": "#FFFFFF",
          secondary: "#ffffff00",
          "secondary-content": "#cc9999",
        },
      },
    ],
  },
  theme: {
    extend: {
      fontFamily: {
        'canvas': ['MADECanvas-Black'],
      },
      colors: {
      },
    },
  },
  plugins: [require("daisyui")],
};
