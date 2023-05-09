const ID = (() => {
  let current = 0;
  let next = () => {
    current++;
    return `n${current}`;
  };
  return { next };
})();

export default ID;
