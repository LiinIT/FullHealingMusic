// ─── THEME ───────────────────────────────────────────────────────────────────
const THEME = (() => {
    const KEY = 'hm_theme';

    function apply(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem(KEY, theme);
        const icon = document.getElementById('theme-icon');
        const label = document.getElementById('dropdown-theme-label');
        if (theme === 'light') {
            if (icon) { icon.className = 'fa-solid fa-sun'; }
            if (label) label.textContent = 'Chuyển Dark Mode';
        } else {
            if (icon) { icon.className = 'fa-solid fa-moon'; }
            if (label) label.textContent = 'Chuyển Light Mode';
        }
    }

    function toggle() {
        const current = localStorage.getItem(KEY) || 'dark';
        apply(current === 'dark' ? 'light' : 'dark');
    }

    function init() {
        const saved = localStorage.getItem(KEY) || 'dark';
        apply(saved);
    }

    return { init, toggle, apply };
})();

// ─── ADMIN PROFILE ────────────────────────────────────────────────────────────
const PROFILE = (() => {
    function toggle() {
        const dropdown = document.getElementById('profile-dropdown');
        const profileEl = document.getElementById('admin-profile');
        if (!dropdown) return;
        const isOpen = dropdown.classList.contains('show');
        if (isOpen) {
            close();
        } else {
            dropdown.classList.add('show');
            profileEl.classList.add('open');
        }
    }

    function close() {
        const dropdown = document.getElementById('profile-dropdown');
        const profileEl = document.getElementById('admin-profile');
        if (dropdown) dropdown.classList.remove('show');
        if (profileEl) profileEl.classList.remove('open');
    }

    function openChangePassword() {
        close();
        document.getElementById('cp-current').value = '';
        document.getElementById('cp-new').value = '';
        document.getElementById('cp-confirm').value = '';
        document.getElementById('cp-error').style.display = 'none';
        document.getElementById('modal-change-password').classList.add('show');
    }

    function closeChangePassword() {
        document.getElementById('modal-change-password').classList.remove('show');
    }

    async function submitChangePassword() {
        const current = document.getElementById('cp-current').value;
        const newPw = document.getElementById('cp-new').value;
        const confirm = document.getElementById('cp-confirm').value;
        const errorEl = document.getElementById('cp-error');

        errorEl.style.display = 'none';

        if (!current || !newPw || !confirm) {
            errorEl.textContent = 'Vui lòng điền đầy đủ các trường';
            errorEl.style.display = 'block';
            return;
        }
        if (newPw.length < 6) {
            errorEl.textContent = 'Mật khẩu mới tối thiểu 6 ký tự';
            errorEl.style.display = 'block';
            return;
        }
        if (newPw !== confirm) {
            errorEl.textContent = 'Mật khẩu xác nhận không khớp';
            errorEl.style.display = 'block';
            return;
        }

        const btn = document.querySelector('#modal-change-password .btn-primary');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang cập nhật...';

        try {
            const res = await postAPI('/auth/change-password', { currentPassword: current, newPassword: newPw });
            if (res.done) {
                closeChangePassword();
                showToast('Đổi mật khẩu thành công', 'success');
            } else {
                errorEl.textContent = res.message || 'Mật khẩu hiện tại không đúng';
                errorEl.style.display = 'block';
            }
        } catch {
            errorEl.textContent = 'Lỗi kết nối, thử lại sau';
            errorEl.style.display = 'block';
        }

        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check"></i> Cập nhật';
    }

    return { toggle, close, openChangePassword, closeChangePassword, submitChangePassword };
})();

function toggleFieldPassword(fieldId, btn) {
    const input = document.getElementById(fieldId);
    const icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.className = 'fa-solid fa-eye-slash';
    } else {
        input.type = 'password';
        icon.className = 'fa-solid fa-eye';
    }
}

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

    // Init theme & language (after HTML loaded)
    THEME.init();
    I18N.init();
    I18N.apply();
    // Hiển thị label nút ngôn ngữ đúng
    const langLabel = document.getElementById('lang-btn-label');
    if (langLabel) langLabel.textContent = I18N.lang() === 'en' ? 'VN' : 'EN';

    // Điền thông tin user
    const user = AUTH.getUser();
    if (user) {
        const initials = user.username.slice(0, 2).toUpperCase();
        // Sidebar
        const nameEl = document.querySelector('.user-name');
        const initEl = document.querySelector('.user-avatar');
        if (nameEl) nameEl.textContent = user.username;
        if (initEl) initEl.textContent = initials;
        // Topbar
        const topbarName = document.getElementById('topbar-name');
        const topbarAvatar = document.getElementById('topbar-avatar');
        const dropdownName = document.getElementById('dropdown-name');
        const dropdownAvatar = document.getElementById('dropdown-avatar');
        const dropdownEmail = document.getElementById('dropdown-email');
        if (topbarName) topbarName.textContent = user.username;
        if (topbarAvatar) topbarAvatar.textContent = initials;
        if (dropdownName) dropdownName.textContent = user.username;
        if (dropdownAvatar) dropdownAvatar.textContent = initials;
        if (dropdownEmail && user.email) dropdownEmail.textContent = user.email;
    }

    // Close dropdown khi click outside (chỉ đăng ký 1 lần)
    if (!window._profileClickListenerAdded) {
        window._profileClickListenerAdded = true;
        document.addEventListener('click', (e) => {
            const profileEl = document.getElementById('admin-profile');
            if (profileEl && !profileEl.contains(e.target)) PROFILE.close();
        });
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

    // Topbar search → search all (overview)
    const topbarSearch = document.getElementById('topbar-search-input');
    if (topbarSearch) {
        topbarSearch.addEventListener('input', e => {
            const q = e.target.value;
            navigate('overview');
            // Đồng bộ query sang overview search input
            const ovInput = document.getElementById('overview-search-input');
            if (ovInput) ovInput.value = q;
            searchOverview(q);
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

