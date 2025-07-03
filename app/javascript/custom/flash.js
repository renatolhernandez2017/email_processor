window.showFlash = function(message, type = "info") {
  const container = document.querySelector('[data-controller="notifications"]')
  if (!container) return

  const el = document.createElement("div")
  el.className = `alert alert-${type} shadow-lg p-4 gap-2 w-[98%] text-black mx-auto mt-4 transition-opacity duration-500`
  el.innerHTML = `
    <span>${message}</span>
    <div class="flex justify-end w-full">
      <button type="button" onclick="this.parentElement.remove()" class="btn btn-ghost">✕</button>
    </div>
  `
  container.appendChild(el)

  setTimeout(() => {
    el.classList.add("opacity-0")
    setTimeout(() => el.remove(), 500)
  }, 5000)
}
