import { convertResizeImageFiles } from './image_utils'

// This hook attaches to a custom input element to resize selected images.
export default ResizeInput = {
  getUploadTarget() { return this.el.dataset.uploadTarget },
  mounted() {
    this.el.addEventListener("change", (e) => {
      e.preventDefault()
      e.stopImmediatePropagation()

      if (this.el.files && this.el.files.length > 0) {
        convertResizeImageFiles(this.el.files, 300, (resizedImageBlob) => {
          // Enqueues the resized blob on the <.live_file_input />.
          this.upload(this.getUploadTarget(), [resizedImageBlob])
        })
      }
    })
  }
}
