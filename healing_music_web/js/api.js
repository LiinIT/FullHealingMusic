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
async function loadSongsFromAPI() {
    const { success, data } = await fetchAPI('/songs');
    if (success && data.songs) {
        DATA.songs = data.songs;
        renderSongs(DATA.songs);

        // Update count
        const songsCount = document.getElementById('songs-count');
        const isongCount = document.getElementById('isong-count');
        const totalOverView = document.getElementById('total-songs-value');
        if (songsCount) songsCount.innerText = `${DATA.songs.length} bài hát`;
        if (isongCount) isongCount.innerText = `${DATA.songs.length}`;
        if (totalOverView) totalOverView.innerText = `${DATA.songs.length}`;
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