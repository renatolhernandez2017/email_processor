import consumer from "./consumer"

window.subscribeToClosing = function(closingId) {
  consumer.subscriptions.create(
    { channel: "ClosingChannel", closing_id: closingId },
    {
      received(data) {
        if (window.showFlash) {
          window.showFlash(data.message)
        }
      }
    }
  )
}
