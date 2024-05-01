import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    id: String,
  };

  delete() {
    this.dispatch('delete', {
      detail: {
        id: this.idValue,
      },
    });
  }
}
