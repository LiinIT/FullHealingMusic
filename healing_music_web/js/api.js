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
    }
}

async function loadAlbumFromAPI() {
    const { success, data } = await postAPI('/artists/album', { action: 'getAllAlbums' });
    if (success && data.albums) {
        DATA.albums = data.albums;
    }
}
async function loadArtistFromAPI() {
    const { success, data } = await postAPI('/artists/get_all', { action: 'getAll' });
    if (success && data.artists) {
        DATA.artists = data.artists;
        loadAlbumFromAPI()
        renderArtists(DATA.artists);
    }
}

async function loadUserFromAPI() {
    const { success, data } = await postAPI('/users/crud_user', { action: 'getAll' });
    if (success && data.users) {
        DATA.users = data.users;
        console.log(DATA.users)
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
