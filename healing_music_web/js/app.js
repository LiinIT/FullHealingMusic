// Main initialization
document.addEventListener('DOMContentLoaded', async () => {
    // === THÊM ĐOẠN NÀY: Load HTML components ===
    await HTML_LOADER.loadAll();
    // === KẾT THÚC ===

    // Update topbar icons
    const searchBtn = document.querySelector('.topbar-search button');
    if (searchBtn) searchBtn.innerHTML = ICONS.ui.search;

    const bellBtn = document.querySelector('.topbar-actions .icon-btn:nth-child(1)');
    if (bellBtn) bellBtn.innerHTML = ICONS.ui.bell;

    const themeBtn = document.querySelector('.topbar-actions .icon-btn:nth-child(2)');
    if (themeBtn) themeBtn.innerHTML = ICONS.ui.moon;

    const userBtn = document.querySelector('.topbar-actions .icon-btn:nth-child(3)');
    if (userBtn) userBtn.innerHTML = ICONS.ui.user;

    // Load data from API
    await loadSongsFromAPI();
    await loadArtistFromAPI();

    // Render pages
    renderSongs();
    renderOverview();
    renderArtists();
    renderUsers();

    // Navigation
    navigate('overview');

    // Topbar search routing
    const topbarSearch = document.getElementById('topbar-search-input');
    if (topbarSearch) {
        topbarSearch.addEventListener('input', e => {
            const q = e.target.value;
            if (q.length > 0) {
                navigate('songs');
                searchSongs(q);
            } else {
                renderSongs(DATA.songs);
            }
        });
    }

    // Page song search
    const songsSearch = document.getElementById('songs-search');
    if (songsSearch) {
        songsSearch.addEventListener('input', e => searchSongs(e.target.value));
    }

    // Close modal on overlay click
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => {
            if (e.target === overlay) overlay.classList.remove('show');
        });
    });
});

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

    selectedFiles[type].image = file;

    const prefix = type === 'create' ? 'new' : 'edit';

    const preview = document.getElementById(`${prefix}-image-preview`);
    const label = document.getElementById(`${prefix}-image-filename`);

    label.textContent = file.name;

    const blobUrl = URL.createObjectURL(file);
    preview.src = blobUrl;
    preview.style.display = 'block';
}

async function uploadFile(file) {
    try {
        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch(`${CONFIG.API_BASE_URL}/upload`, {
            method: 'POST',
            body: formData,  // KHÔNG set Content-Type thủ công
        });

        const data = await response.json();

        if (data.done) {
            console.log('Uploaded:', data.url);
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