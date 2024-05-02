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
    console.log('add');
    console.log(stack);
    console.log(redo);
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
    console.log('undo');
    console.log(stack);
    console.log(redo);
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
    console.log('redo');
    console.log(stack);
    console.log(redo);
  };

  return obj;
}
