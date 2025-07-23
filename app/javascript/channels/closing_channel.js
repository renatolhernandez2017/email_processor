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
        console.log("✅ Conectado ao NotificationChannel")
      },
      disconnected() {
        console.log("❌ Desconectado do NotificationChannel")
      },
      received(data) {
        if (window.showFlash) {
          window.showFlash(data.message);
        }
      }
    }
  )
}
