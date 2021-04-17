const UPLOAD_JITTER = [2000, 4000]

function markCompleted(uploadedEntry) {
  uploadedEntry.progress(100)
  console.log("entry complete", uploadedEntry)
}

function randomWait() {
  let [minMs, maxMs] = UPLOAD_JITTER
  return Math.floor(Math.random() * (maxMs - minMs + 1)) + minMs
}

function simulateFileUploadWithJitter(uploadEntry) {
  let afterMs = randomWait()

  setTimeout(() => uploadEntry.progress(25), afterMs)
  setTimeout(() => uploadEntry.progress(50), afterMs * 2)
  setTimeout(() => uploadEntry.progress(75), afterMs * 3)
  setTimeout(() => markCompleted(uploadEntry), afterMs * 4)
}

const Uploaders = {}

Uploaders.WithJitter = function (entries) {
  entries.forEach(entry => {
    let { file, meta } = entry
    console.log("[Uploaders.WithJitter] received file", meta, file)
    simulateFileUploadWithJitter(entry)
  })
}

Uploaders.NoJitter = function (entries) {
  entries.forEach(entry => {
    let { file, meta } = entry
    let waitMs = randomWait()
    console.log(`[Uploaders.NoJitter] received file, waiting ${waitMs}`, meta, file)
    setTimeout(() => markCompleted(entry), waitMs)
  })
}

Uploaders.NoWait = function (entries) {
  entries.forEach(entry => {
    let { file, meta } = entry
    console.log(`[Uploaders.NoWait] received file`, meta, file)
    setTimeout(() => markCompleted(entry), 100)
  })
}

export default Uploaders
