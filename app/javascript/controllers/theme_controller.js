import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.loadTheme()
  }

  loadTheme() {
    const savedTheme = localStorage.getItem("theme") || "light"
    document.documentElement.setAttribute("data-theme", savedTheme)
    this.updateToggle(savedTheme)
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const newTheme = currentTheme === "dark" ? "light" : "dark"

    document.documentElement.setAttribute("data-theme", newTheme)
    localStorage.setItem("theme", newTheme)
    this.updateToggle(newTheme)
  }

  updateToggle(theme) {
    if (this.hasToggleTarget) {
      this.toggleTarget.checked = theme === "dark"
    }
  }
}
