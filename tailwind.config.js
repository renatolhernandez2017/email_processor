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
          primary: "#1a309c00",
          "primary-content": "#FFFFFF",
          secondary: "#ffffff00",
          "secondary-content": "#cc9999",
          accent: "#de9e85",
          "accent-content": "#150406",
          neutral: "#fffcf3",
          "neutral-content": "#bebebe",
          info: "#e5e7eb",
          "info-content": "#121313",
          success: "#33902A",
          "success-content": "#ffffff",
          warning: "#F0AD00",
          "warning-content": "#FFFFFF",
          error: "#FD627A",
          "error-content": "#fff",
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
