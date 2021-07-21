// This hook demonstrates a way for a user to record media
// directly in their browser and upload it to the web server (or
// external source) via LiveView.

function SimpleRecorder(stream, mimeType, callback) {
  let chunks = [];
  let recorder = new MediaRecorder(stream, { type: mimeType })

  recorder.addEventListener("dataavailable", event => {
    if (typeof event.data === "undefined") return
    if (event.data.size === 0) return
    chunks.push(event.data)
  })

  recorder.addEventListener("stop", () => {
    let recording = new Blob(chunks, { type: mimeType })
    callback(recording)
    chunks = []
  })

  return {
    get state() { return recorder.state },
    start(timeslice) { recorder.start(timeslice) },
    stop() { recorder.stop() }
  }
}

let MediaRecorderDemo = {
  mounted() {
    if (!('MediaRecorder' in window)) {
      this.pushEvent("media-recorder:client:error", { "reason": "not_supported" })
      return
    }

    this.handleEvent("media-recorder:server:request", async ({ name }) => {
      try {
        let stream = await navigator.mediaDevices.getUserMedia({
          audio: true,
          video: false
        })

        this.recorder = SimpleRecorder(stream, "audio/webm", blob => {
          blob.name = "My Recording.webm"
          this.upload(name, [blob])
        })

        this.pushEvent("media-recorder:client:ready", { name })
      } catch {
        this.pushEvent("media-recorder:client:error", { "reason": "access_denied" })
      }
    })

    this.handleEvent("media-recorder:server:start", () => this.recorder && this.recorder.start())
    this.handleEvent("media-recorder:server:stop", () => this.recorder && this.recorder.stop())
  }
}

export default MediaRecorderDemo
