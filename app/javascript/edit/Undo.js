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
    console.log(stack);
    console.log(redo);
  };

  obj.undo = function () {
    if (stack.length > 0) {
      let action = stack.pop();
      action.reverse();
      redo.push(action);
    }
    console.log(stack);
    console.log(redo);
  };

  obj.redo = function () {
    if (redo.length > 0) {
      let action = redo.pop();
      action.action();
      stack.push(action);
    }
    console.log(stack);
    console.log(redo);
  };

  return obj;
}
