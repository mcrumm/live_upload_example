const MediaStreamRecorder = {
    renderError(message) {
        this.el.innerHTML = `<div class="error"><p>${message}</p></div>`;
    },
    mounted() {
        const getMic = document.getElementById('mic');
        const recordButton = document.getElementById('record');

        if ('MediaRecorder' in window) {
            getMic.addEventListener('click', async () => {
                getMic.classList.toggle('visually-hidden');
                try {
                    const stream = await navigator.mediaDevices.getUserMedia({
                        audio: true,
                        video: false
                    });
                    const mimeType = 'audio/webm';
                    let chunks = [];
                    const recorder = new MediaRecorder(stream, {
                        type: mimeType
                    });
                    recorder.addEventListener('dataavailable', event => {
                        if (typeof event.data === 'undefined') return;
                        if (event.data.size === 0) return;
                        chunks.push(event.data);
                    });
                    recorder.addEventListener('stop', () => {
                        const recording = new Blob(chunks, {
                            type: mimeType
                        });
                        this.upload("notes", [recording]);
                        chunks = [];
                    });
                    recordButton.classList.toggle('visually-hidden');
                    recordButton.addEventListener('click', () => {
                        if (recorder.state === 'inactive') {
                            recorder.start();
                            recordButton.innerText = 'Stop';
                        } else {
                            recorder.stop();
                            recordButton.innerText = 'Record';
                        }
                    });
                } catch {
                    this.renderError(
                        'You denied access to the microphone so this demo will not work.'
                    );
                }
            });
        } else {
            this.renderError(
                "Sorry, your browser doesn't support the MediaRecorder API, so this demo will not work."
            );
        }
    }
};

export default MediaStreamRecorder;
