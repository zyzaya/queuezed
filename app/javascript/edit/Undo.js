export default function Undo() {
  let obj = {};
  let redo = [];
  let stack = [];

  obj.add = function (name, action, reverse) {
    action();
    stack.push({
      name,
      action,
      reverse,
    });
  };

  obj.undo = function () {
    if (stack.length > 0) {
      let action = stack.pop();
      action.reverse();
      redo.push(action);
    }
  };

  obj.redo = function () {
    if (redo.length > 0) {
      let action = redo.pop();
      action.action();
      stack.push(action);
    }
  };

  return obj;
}
