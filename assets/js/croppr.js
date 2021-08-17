import Croppr from "../vendor/croppr.js"

function cropprToBlob(el, { height, width, x, y }, callback) {
  const canvas = document.createElement("canvas")
  const context = canvas.getContext("2d")
  canvas.width = width
  canvas.height = height
  context.drawImage(el, x, y, width, height, 0, 0, canvas.width, canvas.height)
  canvas.toBlob(callback, "image/jpeg", 0.9)
}

let Hook = {
  mounted() {
    this.handleEvent("croppr:destroy", ({ name }) => {
      if (name === this.el.dataset.uploadName) {
        if (this.croppr) {
          this.croppr.destroy()
          this.img && this.el.removeChild(this.img)
          this.img && URL.revokeObjectURL(this.img.src)
          this.img = null
          this.croppr = null
        }
      }
    })

    this.el.addEventListener("dragover", e => e.preventDefault())
    this.el.addEventListener("drop", e => {
      e.preventDefault()
      let files = Array.from(e.dataTransfer.files || [])
      if (files.length > 0) {
        let [file] = files
        this.img && URL.revokeObjectURL(this.img.src)
        this.croppr && this.croppr.destroy()
        this.img = new Image()
        this.img.src = URL.createObjectURL(file)
        this.el.appendChild(this.img)
        this.croppr = new Croppr(this.img, {
          onCropEnd: vals => cropprToBlob(this.img, vals, blob => this.upload(this.el.dataset.uploadName, [blob]))
        })
      }
    })
  },
  destroyed() {
    this.croppr && this.croppr.destroy()
  }
}

export default Hook
