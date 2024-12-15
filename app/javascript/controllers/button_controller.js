import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  loading({ target }) {
    const originalContent = target.innerHTML
    target.innerHTML = `
      <span class="d-flex align-items-center">
        <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
        <span>Processing...</span>
      </span>
    `
    this.element.addEventListener(
      'turbo:submit-end',
      () => {
        target.innerHTML = originalContent
        target.classList.remove('disabled')
      },
      { once: true }
    )
  }
}
