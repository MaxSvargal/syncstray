const makeCancelable = promise => {
  let hasCanceled = false
  return {
    promise: new Promise((resolve, reject) =>
      promise.then(r => (hasCanceled ?
          reject({ isCanceled: true }) :
          resolve(r)))),
    cancel() {
      hasCanceled = true
    }
  }
}

const deferer = makeCancelable(
  new Promise(resolve => setTimeout(resolve, 1)))

export { makeCancelable, deferer }
