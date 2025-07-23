import consumer from "./consumer"

let closingSubscription;

window.subscribeToClosing = function(closingId) {
  if (!closingId) return;

  if (closingSubscription) {
    consumer.subscriptions.remove(closingSubscription);
  }

  closingSubscription = consumer.subscriptions.create(
    { channel: "ClosingChannel", closing_id: closingId },
    {
      connected() {
        console.log("✅ Conectado ao ClosingChannel")
      },
      disconnected() {
        console.log("❌ Desconectado do ClosingChannel")
      },
      received(data) {
        const element = document.querySelector('[data-controller="notification"]');
        if (element) {
          element.dispatchEvent(new CustomEvent("notification:show", { detail: data }));
        }
      }
    }
  )
}
