export default class Undo {
  static #redo = [];
  static #stack = [];
  static #changes = [];

  static add(name, action, reverse) {
    action();
    this.#stack.push({
      name,
      action,
      reverse,
    });
    this.#changes.push('action');
    this.#redo.length = 0;
  }

  static undo() {
    if (this.#stack.length <= 0) return;
    let element = this.#stack.pop();
    element.reverse();

    this.#redo.push(element);

    let length = this.#changes.length;
    if (length > 0 && ['action', 'redo'].includes(this.#changes[length - 1])) {
      this.#changes.pop();
    } else {
      this.#changes.push('undo');
    }
  }

  static redo() {
    if (this.#redo.length <= 0) return;
    let element = this.#redo.pop();
    element.action();
    this.#stack.push(element);

    let length = this.#changes.length;
    if (length > 0 && this.#changes[length - 1] === 'undo') {
      this.#changes.pop();
    } else {
      this.#changes.push('redo');
    }
  }

  static reset_changes() {
    this.#changes.length = 0;
  }

  static has_changes() {
    return this.#changes.length > 0;
  }
}
