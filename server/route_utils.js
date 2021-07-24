function recent_uniques(arr, new_entry) {
  let unique = true;
  for (let i = 0; i < arr.length; i++) {
    if (arr[i].recent_id === new_entry.recent_id) {
      unique = false;
      arr[i] = new_entry;
    }
  }
  if (unique) {
    arr.push(new_entry);
  }
  return arr;
}

module.exports = {
  recent_uniques,
};
