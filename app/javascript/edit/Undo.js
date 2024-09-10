export default class Undo {
  static #redo = [];
  static #stack = [];

  static add(name, action, reverse) {
    action();
    this.#stack.push({
      name,
      action,
      reverse,
    });
  }

  static undo() {
    if (this.#stack.length <= 0) return;
    let element = this.#stack.pop();
    element.reverse();
    this.#redo.push(element);
  }

  static redo() {
    if (this.#redo.length <= 0) return;
    let element = this.#redo.pop();
    element.action();
    this.#stack.push(element);
  }
}
