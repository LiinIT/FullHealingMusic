// ─── LOGIN UI ────────────────────────────────────────────────────────────────
function showLoginScreen() {
    document.getElementById('login-screen').style.display = 'flex';
    document.getElementById('app-layout').style.display = 'none';
    document.getElementById('login-username').focus();
}

function hideLoginScreen() {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('app-layout').style.display = 'flex';
}

async function doLogin() {
    const username = document.getElementById('login-username').value.trim();
    const password = document.getElementById('login-password').value;
    const errorEl = document.getElementById('login-error');
    const btn = document.getElementById('login-btn');

    if (!username || !password) {
        errorEl.textContent = 'Vui lòng nhập đầy đủ thông tin';
        return;
    }

    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang đăng nhập...';
    errorEl.textContent = '';

    const result = await AUTH.login(username, password);

    btn.disabled = false;
    btn.innerHTML = '<i class="fa-solid fa-right-to-bracket"></i> Đăng nhập';

    if (!result.success) {
        errorEl.textContent = result.message;
        return;
    }

    hideLoginScreen();
    await initApp();
}

function toggleLoginPassword(btn) {
    const input = document.getElementById('login-password');
    const icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.className = 'fa-solid fa-eye-slash';
    } else {
        input.type = 'password';
        icon.className = 'fa-solid fa-eye';
    }
}

// ─── APP INIT ────────────────────────────────────────────────────────────────
async function initApp() {
    await HTML_LOADER.loadAll();

    // Điền tên user vào sidebar footer
    const user = AUTH.getUser();
    if (user) {
        const nameEl = document.querySelector('.user-name');
        const initEl = document.querySelector('.user-avatar');
        if (nameEl) nameEl.textContent = user.username;
        if (initEl) initEl.textContent = user.username.slice(0, 2).toUpperCase();
    }

    // Load data from API
    await loadSongsFromAPI();
    await loadArtistFromAPI();
    await loadUserFromAPI();

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
                searchSongs('topbar-search-input');
            } else {
                renderSongs(DATA.songs);
            }
        });
    }

    // Close modal on overlay click
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => {
            if (e.target === overlay) overlay.classList.remove('show');
        });
    });
}

// ─── MAIN ENTRY ──────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
    if (AUTH.isLoggedIn()) {
        hideLoginScreen();
        await initApp();
    } else {
        showLoginScreen();
    }
});

