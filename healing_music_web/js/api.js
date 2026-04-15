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

    isLoggedIn() {
        if (!this.getToken()) return false;
        const user = this.getUser();
        // Nếu user được lưu mà không có role hoặc role khác admin thì coi như chưa đăng nhập
        if (user && user.role && user.role.toLowerCase() !== 'admin') {
            this.clear();
            return false;
        }
        return true;
    },

    async login(username, password) {
        try {
            const res = await fetch(`${CONFIG.API_BASE_URL}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password }),
            });
            const data = await res.json();
            if (!res.ok) return { success: false, message: data.message || 'Đăng nhập thất bại' };

            // Chỉ cho phép role "admin" đăng nhập vào trang quản trị
            const role = (data.role || '').toLowerCase();
            if (role !== 'admin') {
                return {
                    success: false,
                    message: 'Tài khoản không có quyền truy cập trang quản trị. Chỉ Admin mới được phép đăng nhập.',
                };
            }

            this.save(data.token, { id: data.userID, username: data.username, email: data.email, role });
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

    const audioName = document.getElementById('new-audio-filename');
    const imageName = document.getElementById('song-image-filename');
    const audioPreview = document.getElementById('new-audio-preview');
    const imagePreview = document.getElementById('song-image-preview');

    if (audioName) audioName.innerHTML = 'Chưa chọn file';
    if (imageName) imageName.innerHTML = 'Chưa chọn file';

    if (audioPreview) { audioPreview.src = ''; audioPreview.style.display = 'none'; }
    if (imagePreview) { imagePreview.src = ''; imagePreview.style.display = 'none'; }

    // reset file input elements
    const audioInput = document.getElementById('new-audio-file-input');
    const imageInput = document.getElementById('new-image-file-input');
    if (audioInput) audioInput.value = '';
    if (imageInput) imageInput.value = '';

    // reset file state
    if (typeof selectedFiles !== 'undefined') {
        selectedFiles.song = { audio: null, image: null };
    }
}
