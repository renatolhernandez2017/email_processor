var __getOwnPropNames = Object.getOwnPropertyNames;
var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};

// app/javascript/cable.js
var require_cable = __commonJS({
  "app/javascript/cable.js"(exports) {
    (function() {
      this.App || (this.App = {});
      App.cable = ActionCable.createConsumer();
      consumer = App.cable;
    }).call(exports);
  }
});
export default require_cable();
//# sourceMappingURL=/assets/cable.js.map
