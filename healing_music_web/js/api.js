// ─── FETCH HELPERS ───────────────────────────────────────────────────────────
async function fetchAPI(endpoint, options = {}) {
    const url = `${CONFIG.API_BASE_URL}${endpoint}`;
    try {
        const response = await fetch(url, {
            headers: { 'Content-Type': 'application/json' },
            ...options,
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        return { success: true, data: await response.json() };
    } catch (error) {
        console.error('Fetch error:', error);
        return { success: false, error: error.message };
    }
}

function postAPI(endpoint, body) {
    return fetchAPI(endpoint, {
        method: 'POST',
        body: JSON.stringify(body),
    });
}


// ─── LOAD DATA ───────────────────────────────────────────────────────────────
// Chỉ khai báo 1 lần — bỏ bản trùng ở trên
async function loadSongsFromAPI() {
    const { success, data } = await fetchAPI('/songs');
    if (success && data.songs) {
        DATA.songs = data.songs;
        renderSongs(DATA.songs);
        const ranked = data.songs
            .filter(s => s.rank != null)
            .sort((a, b) => a.rank - b.rank);
        // renderTopTracks(ranked);
    }
}

async function loadArtistFromAPI() {
    const { success, data } = await postAPI('/artists/get_all', { action: 'getAll' });
    if (success && data.artists) {
        DATA.artists = data.artists;
        renderArtists(DATA.artists);
    }
}

async function loadAlbumFromAPI() {
    const { success, data } = await postAPI('/artist_albums', { action: 'getAllAlbums' });
    if (success && data.albums) {
        DATA.albums = data.albums;
        renderAlbums(DATA.albums);
    }
}
async function openAddSongModal() {
    resetAddSongForm();

    const select = document.getElementById('new-song-artist-id');
    if (select) loadOptionArtist(select);

    openModal('modal-add-song');
}

function resetAddSongForm() {
    // reset input
    ['new-song-title', 'new-song-artist-id', 'new-song-duration']
        .forEach(id => {
            const el = document.getElementById(id);
            if (el) el.value = '';
        });

    // FIX ID đúng
    const audioName = document.getElementById('new-audio-filename');
    const imageName = document.getElementById('new-image-filename');
    const audioPreview = document.getElementById('new-audio-preview');
    const imagePreview = document.getElementById('new-image-preview');

    if (audioName) audioName.innerHTML = 'Chưa chọn file';
    if (imageName) imageName.innerHTML = 'Chưa chọn file';

    if (audioPreview) audioPreview.style.display = 'none';
    if (imagePreview) imagePreview.style.display = 'none';

    // reset file state
    if (typeof selectedFiles !== 'undefined') {
        selectedFiles.create = { audio: null, image: null };
    }
}

// ─── ADD ARTIST ──────────────────────────────────────────────────────────────
async function addArtist() {
    const fullName = document.getElementById('new-artist-name')?.value?.trim();
    const avatarUrl = document.getElementById('new-artist-avatar')?.value?.trim();
    const bio = document.getElementById('new-artist-bio')?.value?.trim();

    if (!fullName) { showToast('⚠️ Tên nghệ sĩ là bắt buộc', 'error'); return; }

    const { success, data } = await postAPI('/artists/manage', {
        action: 'addArtist',
        fullName,
        avatarUrl: avatarUrl || `https://picsum.photos/id/${Math.floor(Math.random() * 100)}/500/500`,
        bio: bio || null,
    });

    if (success && data.done) {
        showToast(`✅ Thêm nghệ sĩ thành công! ID: ${data.id}`, 'success');
        closeModal('modal-add-artist');
        await loadArtistFromAPI();
    } else {
        showToast(`❌ ${data?.message ?? 'Thêm thất bại'}`, 'error');
    }
}

// ─── ADD ALBUM ───────────────────────────────────────────────────────────────
async function addAlbum() {
    const title = document.getElementById('new-album-title')?.value?.trim();
    const artistId = document.getElementById('new-album-artist-id')?.value?.trim();
    const albumType = document.getElementById('new-album-type')?.value ?? 'album';
    const coverUrl = document.getElementById('new-album-cover')?.value?.trim();

    if (!title || !artistId) {
        showToast('⚠️ Tên album và Artist ID là bắt buộc', 'error');
        return;
    }

    const { success, data } = await postAPI('/artist_albums', {
        action: 'addAlbum',
        artistId: parseInt(artistId),
        title, albumType,
        coverUrl: coverUrl || null,
    });

    if (success && data.done) {
        showToast(`✅ Thêm album thành công! ID: ${data.id}`, 'success');
        closeModal('modal-add-album');
        await loadAlbumFromAPI();
    } else {
        showToast(`❌ ${data?.message ?? 'Thêm thất bại'}`, 'error');
    }
}

// ─── ADD SONG TO ALBUM ───────────────────────────────────────────────────────
async function addSongToAlbum(albumId, songId, trackNumber = 999) {
    const { success, data } = await postAPI('/artist_albums', {
        action: 'addSongToAlbum',
        albumId, songId, trackNumber,
    });
    if (success && data.done) {
        showToast('✅ Đã thêm bài hát vào album', 'success');
    } else {
        showToast(`❌ ${data?.message ?? 'Thất bại'}`, 'error');
    }
}

// ─── INIT ────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
    // Load data song song
    await Promise.all([
        loadSongsFromAPI(),
        loadArtistFromAPI(),
    ]);

    // Render các section không cần API
    renderOverview();
    renderUsers();

    // navigate SAU KHI mọi thứ đã render xong
    navigate('overview');
});