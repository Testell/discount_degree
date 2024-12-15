import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    const button = this.element.querySelector('button')
    if (button?.dataset.loading) {
      this.resetButton(button)
    }
  }

  loading({ target }) {
    if (target.dataset.loading) return

    const originalContent = target.innerHTML
    target.dataset.loading = 'true'
    target.innerHTML = `
      <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
      <span>Processing...</span>
    `

    document.addEventListener(
      'turbo:submit-end',
      () => {
        this.resetButton(target)
      },
      { once: true }
    )
  }

  resetButton(button) {
    if (!button.dataset.loading) return

    const originalContent = `
      <i class="fas fa-sync-alt me-2"></i>
      <span>Update from Catalog</span>
    `
    button.innerHTML = originalContent
    button.classList.remove('disabled')
    delete button.dataset.loading
  }
}
