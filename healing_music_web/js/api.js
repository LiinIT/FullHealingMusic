// ─── AUTH ─────────────────────────────────────────────────────────────────────
const AUTH = {
    TOKEN_KEY: 'hm_admin_token',
    USER_KEY: 'hm_admin_user',

    getToken() { return localStorage.getItem(this.TOKEN_KEY); },
    getUser()  { return JSON.parse(localStorage.getItem(this.USER_KEY) || 'null'); },

    save(token, userInfo) {
        localStorage.setItem(this.TOKEN_KEY, token);
        localStorage.setItem(this.USER_KEY, JSON.stringify(userInfo));
    },

    clear() {
        localStorage.removeItem(this.TOKEN_KEY);
        localStorage.removeItem(this.USER_KEY);
    },

    isLoggedIn() { return !!this.getToken(); },

    async login(username, password) {
        try {
            const res = await fetch(`${CONFIG.API_BASE_URL}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password }),
            });
            const data = await res.json();
            if (!res.ok) return { success: false, message: data.message || 'Đăng nhập thất bại' };
            this.save(data.token, { id: data.userID, username: data.username });
            return { success: true, data };
        } catch (e) {
            return { success: false, message: 'Không kết nối được đến server' };
        }
    },

    logout() {
        this.clear();
        showLoginScreen();
    },
};

// ─── FETCH HELPERS ───────────────────────────────────────────────────────────
async function fetchAPI(endpoint, options = {}) {
    const url = `${CONFIG.API_BASE_URL}${endpoint}`;
    const token = AUTH.getToken();

    const headers = { 'Content-Type': 'application/json' };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    try {
        const response = await fetch(url, {
            headers,
            ...options,
            // Merge headers nếu options có truyền thêm
            headers: { ...headers, ...(options.headers || {}) },
        });
        if (response.status === 401) {
            AUTH.clear();
            showLoginScreen();
            return { success: false, error: 'Unauthorized' };
        }
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
        await loadAlbumFromAPI()
        renderArtists(DATA.artists);
    }
}

async function loadUserFromAPI() {
    const { success, data } = await postAPI('/users/crud_user', { action: 'getAll' });
    if (success && data.users) {
        DATA.users = data.users;
        renderUsers();
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
