import consumer from "./consumer"

let emailSubscription;

window.subscribeToEmail = function() {
  if (emailSubscription) {
    consumer.subscriptions.remove(emailSubscription);
  }

  emailSubscription = consumer.subscriptions.create(
    { channel: "EmailChannel" },
    {
      connected() {
        console.log("✅ Conectado ao EmailChannel")
      },
      disconnected() {
        console.log("❌ Desconectado do EmailChannel")
        window.subscribeToEmail()
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
