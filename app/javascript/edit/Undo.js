export default function Undo() {
  let obj = {};
  let redo = [];
  let stack = [];

  obj.add = function (name, action, reverse, pass = false) {
    action();
    stack.push({
      name,
      action,
      reverse,
      pass,
    });
  };

  obj.undo = function () {
    if (stack.length > 0) {
      let pass = true;
      while (pass) {
        let element = stack.pop();
        element.reverse();
        redo.push(element);
        pass = element.pass;
      }
    }
  };

  obj.redo = function () {
    if (redo.length > 0) {
      let pass = true;
      while (pass) {
        let element = redo.pop();
        element.action();
        stack.push(element);
        let next = redo.slice(-1)[0];
        pass = next !== undefined && next.pass;
      }
    }
  };

  return obj;
}
