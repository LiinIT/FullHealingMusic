
// ─── HANDLE AUDIO FILE ───────────────────────────────────────────────────────
function handleAudioFile(type, input) {
    const file = input.files[0];
    if (!file) return;

    selectedFiles[type].audio = file;

    const prefix = type === 'create' ? 'new' : 'edit';

    const filenameEl = document.getElementById(`${prefix}-audio-filename`);
    const preview = document.getElementById(`${prefix}-audio-preview`);
    const durationInput = document.getElementById(`${prefix}-song-duration`);

    filenameEl.textContent = file.name;

    const blobUrl = URL.createObjectURL(file);
    preview.src = blobUrl;
    preview.style.display = 'block';

    preview.onloadedmetadata = () => {
        durationInput.value = Math.round(preview.duration);
    };
}

// ─── HANDLE IMAGE FILE ───────────────────────────────────────────────────────
function handleImageFile(type, input) {
    const file = input.files[0];
    if (!file) return;

    if (!selectedFiles[type]) {
        selectedFiles[type] = {};
    }

    selectedFiles[type].image = file;

    let prefix = type;
    switch (type) {
        case 'create':
            prefix = 'new';
            break;
        case 'edit':
            prefix = 'edit';
            break;
        case 'artist':
            prefix = 'artist';
            break;
    }

    const preview = document.getElementById(`${prefix}-image-preview`);
    const label = document.getElementById(`${prefix}-image-filename`);

    // Kiểm tra xem phần tử có tồn tại không
    if (!preview || !label) {
        return;
    }

    label.textContent = file.name;

    // Tạo URL cho hình ảnh
    const blobUrl = URL.createObjectURL(file);

    preview.src = blobUrl;

    // Hiển thị ảnh
    preview.style.display = 'block';

}

async function uploadFile(file) {
    try {
        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch(`${CONFIG.API_BASE_URL}/upload`, {
            method: 'POST',
            body: formData,
        });

        const data = await response.json();

        if (data.done) {
            return data.url;  // http://127.0.0.1:5500/public/audios/song.mp3
        }

        showToast(`❌ Upload thất bại: ${data.message}`, 'error');
        return null;

    } catch (err) {
        console.error('Upload error:', err);
        showToast('❌ Không thể kết nối server upload', 'error');
        return null;
    }
}