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
function handleAudioFile(input) {
    const file = input.files[0];
    file_song = input.files[0];
    console.log(file_song);

    if (!file) return;

    const filenameEl = document.getElementById('audio-filename');
    const preview = document.getElementById('audio-preview');
    const audioInput = document.getElementById('new-song-audio-url');
    const durationInput = document.getElementById('new-song-duration');

    // Hiện tên file
    filenameEl.textContent = file.name;

    // Blob URL để preview + đọc duration
    const blobUrl = URL.createObjectURL(file);
    preview.src = blobUrl;
    preview.style.display = 'block';

    // Tự động đọc duration từ metadata
    preview.onloadedmetadata = () => {
        const secs = Math.round(preview.duration);
        durationInput.value = secs;
        durationInput.dispatchEvent(new Event('input')); // cập nhật UI nếu có listener
    };

    // Lưu path convention: public/audios/filename.mp3
    audioInput.value = `${CONFIG.WEB_BASE_URL}/${CONFIG.PUBLIC_AUDIO}/${file.name}`;
}

// ─── HANDLE IMAGE FILE ───────────────────────────────────────────────────────
function handleImageFile(input) {
    const file = input.files[0];
    file_img = input.files[0];
    console.log(file_img);

    if (!file) return;

    const preview = document.getElementById('image-preview');
    const imageInput = document.getElementById('new-song-image-url');
    const label = document.getElementById('image-filename');

    label.textContent = file.name;

    // Preview ngay bằng blob
    const blobUrl = URL.createObjectURL(file);
    preview.src = blobUrl;
    preview.style.display = 'block';

    // Lưu path
    imageInput.value = `${CONFIG.WEB_BASE_URL}/${CONFIG.PUBLIC_IMAGE}/${file.name}`;
}


async function openAddSongModal() {
    openModal('modal-add-song');

    const select = document.getElementById('new-song-artist-id');
    select.innerHTML = '<option value="">-- Chọn nghệ sĩ --</option>';

    DATA.artists.forEach(a => {
        const opt = document.createElement('option');
        opt.value = a.id ?? a.artist_id;
        opt.textContent = a.full_name ?? a.name;
        select.appendChild(opt);
    });
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