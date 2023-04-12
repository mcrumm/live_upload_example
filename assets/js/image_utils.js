// Adapted from: https://codesalad.dev/blog/how-to-resize-an-image-in-10-lines-of-javascript-29
function resizeImage(imgEl, wantedWidth, callback) {
  const canvas = document.createElement("canvas")
  const ctx = canvas.getContext("2d")

  const aspect = imgEl.width / imgEl.height

  canvas.width = wantedWidth
  canvas.height = wantedWidth / aspect

  ctx.drawImage(imgEl, 0, 0, canvas.width, canvas.height)
  return canvas.toBlob(callback, "image/jpeg", 0.9)
}

export function convertResizeImageFiles(fileList, wantedWidth, callback) {
  Array.from(fileList).forEach(file => {
    let reader = new FileReader();

    reader.addEventListener("load", () => {
      let imgEl = document.createElement("img")

      imgEl.addEventListener("load", () => {

        resizeImage(imgEl, wantedWidth, (blob) => {

          callback(blob)

        })

      })

      imgEl.src = reader.result
    })

    reader.readAsDataURL(file)
  })
}
