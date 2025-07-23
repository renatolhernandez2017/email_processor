import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    this.isDragging = false
    this.offsetX = 0
    this.offsetY = 0

    this.element.style.position = 'fixed'
    this.element.style.cursor = 'move'

    // Restaura a posição salva
    const savedPosition = JSON.parse(sessionStorage.getItem(this.storageKey()))
    if (savedPosition) {
      this.element.style.left = savedPosition.left
      this.element.style.top = savedPosition.top
    }

    this.element.addEventListener("mousedown", this.onMouseDown)
    document.addEventListener("mousemove", this.onMouseMove)
    document.addEventListener("mouseup", this.onMouseUp)
  }

  disconnect() {
    this.element.removeEventListener("mousedown", this.onMouseDown)
    document.removeEventListener("mousemove", this.onMouseMove)
    document.removeEventListener("mouseup", this.onMouseUp)
  }

  onMouseDown = (event) => {
    this.isDragging = true
    this.offsetX = event.clientX - this.element.getBoundingClientRect().left
    this.offsetY = event.clientY - this.element.getBoundingClientRect().top
    this.element.style.transition = "none"
  }

  onMouseMove = (event) => {
    if (!this.isDragging) return

    const cardWidth = this.element.offsetWidth
    const cardHeight = this.element.offsetHeight
    const maxLeft = window.innerWidth - cardWidth
    const maxTop = window.innerHeight - cardHeight

    let newLeft = event.clientX - this.offsetX
    let newTop = event.clientY - this.offsetY

    newLeft = Math.max(0, Math.min(newLeft, maxLeft))
    newTop = Math.max(0, Math.min(newTop, maxTop))

    this.element.style.left = `${newLeft}px`
    this.element.style.top = `${newTop}px`
    this.element.style.right = "auto"

    // Salva a nova posição
    sessionStorage.setItem(this.storageKey(), JSON.stringify({ left, top }))
  }

  onMouseUp = () => {
    this.isDragging = false
    this.element.style.transition = ""
  }

  storageKey() {
    // Você pode customizar esse identificador, caso tenha mais de um elemento
    return `draggable-position-${this.element.id || this.element.dataset.identifier || "default"}`
  }
}
