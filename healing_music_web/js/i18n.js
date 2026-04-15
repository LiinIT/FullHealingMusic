// ─── INTERNATIONALIZATION (EN / VN) ──────────────────────────────────────────
const I18N = (() => {
    const LANG_KEY = 'hm_lang';

    const dict = {
        // ── Sidebar ──
        'nav.overview':       { en: 'Overview',          vn: 'Tổng quan' },
        'nav.songs':          { en: 'Songs',              vn: 'Bài hát' },
        'nav.artists':        { en: 'Artists & Albums',   vn: 'Nghệ sĩ & Album' },
        'nav.users':          { en: 'Users & Playlists',  vn: 'Người dùng' },
        'nav.notifications':  { en: 'Notifications',      vn: 'Thông báo' },
        'nav.settings':       { en: 'Settings',           vn: 'Cài đặt' },
        'nav.analytics':      { en: 'Analytics',          vn: 'Thống kê' },

        // ── Page titles ──
        'page.overview.title':    { en: 'Overview',              vn: 'Tổng quan' },
        'page.overview.sub':      { en: 'System summary',        vn: 'Tổng quan hệ thống' },
        'page.songs.title':       { en: 'Songs',                 vn: 'Bài hát' },
        'page.songs.sub':         { en: 'Manage songs',          vn: 'Quản lý bài hát' },
        'page.artists.title':     { en: 'Artists & Albums',      vn: 'Nghệ sĩ & Album' },
        'page.artists.sub':       { en: 'Manage artists',        vn: 'Quản lý nghệ sĩ & album' },
        'page.users.title':       { en: 'Users & Playlists',     vn: 'Người dùng' },
        'page.users.sub':         { en: 'Manage users',          vn: 'Quản lý người dùng' },
        'page.notifications.title': { en: 'Notifications',       vn: 'Thông báo' },
        'page.notifications.sub':   { en: 'Push notification management', vn: 'Quản lý thông báo push' },
        'page.settings.title':    { en: 'Settings',              vn: 'Cài đặt' },
        'page.settings.sub':      { en: 'System policies & content', vn: 'Chính sách & nội dung hệ thống' },
        'page.analytics.title':   { en: 'Analytics',             vn: 'Thống kê' },
        'page.analytics.sub':     { en: 'Statistics & data analysis', vn: 'Thống kê & phân tích dữ liệu' },

        // ── Topbar ──
        'topbar.search':      { en: 'Search everything...', vn: 'Tìm tất cả...' },
        'topbar.no_notif':    { en: 'No new notifications', vn: 'Không có thông báo mới' },

        // ── Overview stats ──
        'ov.total_songs':     { en: 'TOTAL SONGS',   vn: 'TỔNG BÀI HÁT' },
        'ov.artists':         { en: 'ARTISTS',        vn: 'NGHỆ SĨ' },
        'ov.active_users':    { en: 'ACTIVE USERS',   vn: 'NGƯỜI DÙNG' },
        'ov.total_plays':     { en: 'TOTAL PLAYS',    vn: 'TỔNG LƯỢT PHÁT' },
        'ov.total_songs_meta':{ en: 'total songs',    vn: 'tổng bài hát' },
        'ov.artists_meta':    { en: 'artists',        vn: 'nghệ sĩ' },
        'ov.users_meta':      { en: 'registered users', vn: 'người dùng đăng ký' },
        'ov.plays_meta':      { en: 'total plays',    vn: 'tổng lượt phát' },
        'ov.top_songs_chart': { en: 'Top Songs by Plays', vn: 'Top bài hát theo lượt phát' },
        'ov.top_tracks':      { en: 'Top Tracks',     vn: 'Top Bài Hát' },
        'ov.see_all':         { en: 'See all',         vn: 'Xem tất cả' },
        'ov.now_playing':     { en: 'NOW PLAYING',     vn: 'ĐANG PHÁT' },
        'ov.activity':        { en: 'Recent Activity', vn: 'Hoạt động gần đây' },
        'ov.search_placeholder': { en: 'Search songs, artists, users...', vn: 'Tìm kiếm bài hát, nghệ sĩ, người dùng...' },
        'ov.no_activity':     { en: 'No activity yet', vn: 'Chưa có hoạt động nào' },
        'ov.no_results':      { en: 'No results found', vn: 'Không tìm thấy kết quả' },
        'ov.plays_unit':      { en: 'plays',            vn: 'lượt phát' },

        // ── Activity feed ──
        'act.song_added':     { en: 'Song <strong>{title}</strong> added by <strong>{artist}</strong>',
                                vn: 'Bài hát <strong>{title}</strong> được thêm bởi <strong>{artist}</strong>' },
        'act.user_signup':    { en: 'New user <strong>{name}</strong> signed up',
                                vn: 'Người dùng mới <strong>{name}</strong> đăng ký' },

        // ── Songs page ──
        'songs.search_placeholder': { en: 'Search songs, artists...', vn: 'Tìm bài hát, nghệ sĩ...' },
        'songs.filter':       { en: 'Filter',           vn: 'Lọc' },
        'songs.add':          { en: 'Add Song',         vn: 'Thêm bài hát' },
        'songs.all':          { en: 'All Songs',        vn: 'Tất cả bài hát' },
        'songs.col_plays':    { en: 'Plays',            vn: 'Lượt phát' },
        'songs.col_song':     { en: 'Song',             vn: 'Bài hát' },
        'songs.col_duration': { en: 'Duration',         vn: 'Thời lượng' },
        'songs.col_actions':  { en: 'Actions',          vn: 'Thao tác' },

        // ── Artists page ──
        'artists.title':      { en: 'Artists',          vn: 'Nghệ sĩ' },
        'artists.add':        { en: 'Add Artist',       vn: 'Thêm nghệ sĩ' },
        'artists.albums':     { en: 'Albums',           vn: 'Album' },
        'artists.add_album':  { en: 'Add Album',        vn: 'Thêm album' },
        'artists.col_album':  { en: 'Album',            vn: 'Album' },
        'artists.col_artist': { en: 'Artist',           vn: 'Nghệ sĩ' },
        'artists.col_tracks': { en: 'Tracks',           vn: 'Bài' },
        'artists.col_plays':  { en: 'Plays',            vn: 'Lượt phát' },
        'artists.col_actions':{ en: 'Actions',          vn: 'Thao tác' },

        // ── Users page ──
        'users.title':        { en: 'Users',            vn: 'Người dùng' },
        'users.invite':       { en: 'Invite User',      vn: 'Mời người dùng' },
        'users.col_user':     { en: 'User',             vn: 'Người dùng' },
        'users.col_email':    { en: 'Email',            vn: 'Email' },
        'users.col_role':     { en: 'Role',             vn: 'Vai trò' },
        'users.col_actions':  { en: 'Actions',          vn: 'Thao tác' },
        'users.playlists':    { en: 'Playlists',        vn: 'Danh sách phát' },

        // ── Analytics ──
        'an.total_plays':     { en: 'TOTAL PLAYS',      vn: 'TỔNG LƯỢT PHÁT' },
        'an.avg_plays':       { en: 'AVG PLAYS / SONG', vn: 'TB LƯỢT PHÁT / BÀI' },
        'an.hot_song':        { en: 'HOT SONG',         vn: 'BÀI HÁT HOT' },
        'an.top_artist':      { en: 'TOP ARTIST',       vn: 'NGHỆ SĨ HÀNG ĐẦU' },
        'an.total_plays_meta':{ en: 'total plays',      vn: 'tổng lượt phát' },
        'an.avg_meta':        { en: 'avg per song',     vn: 'trung bình mỗi bài' },
        'an.hot_meta':        { en: 'plays',            vn: 'lượt phát' },
        'an.top_followers':   { en: 'followers',        vn: 'người theo dõi' },
        'an.chart_top_songs': { en: 'Top 10 Songs by Play Count', vn: 'Top 10 bài hát theo lượt phát' },
        'an.chart_verified':  { en: 'Artist Verified',  vn: 'Xác minh nghệ sĩ' },
        'an.chart_songs_monthly': { en: 'Songs Added per Month', vn: 'Bài hát thêm theo tháng' },
        'an.chart_users_monthly': { en: 'User Signups per Month', vn: 'Người dùng đăng ký theo tháng' },
        'an.chart_artists':   { en: 'Top 10 Artists by Followers', vn: 'Top 10 nghệ sĩ theo người theo dõi' },
        'an.songs_table':     { en: 'Songs Table',      vn: 'Bảng bài hát' },
        'an.col_num':         { en: '#',                vn: '#' },
        'an.col_song':        { en: 'Song',             vn: 'Bài hát' },
        'an.col_artist':      { en: 'Artist',           vn: 'Nghệ sĩ' },
        'an.col_plays':       { en: 'Plays',            vn: 'Lượt phát' },

        // ── Profile dropdown ──
        'profile.change_pw':  { en: 'Change Password',  vn: 'Đổi mật khẩu' },
        'profile.light_mode': { en: 'Switch Light Mode',vn: 'Chuyển Light Mode' },
        'profile.dark_mode':  { en: 'Switch Dark Mode', vn: 'Chuyển Dark Mode' },
        'profile.logout':     { en: 'Logout',           vn: 'Đăng xuất' },

        // ── Change password modal ──
        'pw.title':           { en: 'Change Password',  vn: 'Đổi mật khẩu' },
        'pw.current':         { en: 'Current Password', vn: 'Mật khẩu hiện tại' },
        'pw.new':             { en: 'New Password',     vn: 'Mật khẩu mới' },
        'pw.confirm':         { en: 'Confirm Password', vn: 'Xác nhận mật khẩu mới' },
        'pw.current_ph':      { en: 'Enter current password', vn: 'Nhập mật khẩu hiện tại' },
        'pw.new_ph':          { en: 'Minimum 6 characters',   vn: 'Tối thiểu 6 ký tự' },
        'pw.confirm_ph':      { en: 'Re-enter new password',  vn: 'Nhập lại mật khẩu mới' },
        'pw.cancel':          { en: 'Cancel',            vn: 'Hủy' },
        'pw.update':          { en: 'Update',            vn: 'Cập nhật' },
        'pw.updating':        { en: 'Updating...',       vn: 'Đang cập nhật...' },
        'pw.err_fill':        { en: 'Please fill all fields',     vn: 'Vui lòng điền đầy đủ các trường' },
        'pw.err_short':       { en: 'Password must be at least 6 characters', vn: 'Mật khẩu mới tối thiểu 6 ký tự' },
        'pw.err_match':       { en: 'Passwords do not match',     vn: 'Mật khẩu xác nhận không khớp' },
        'pw.err_wrong':       { en: 'Current password is incorrect', vn: 'Mật khẩu hiện tại không đúng' },
        'pw.err_conn':        { en: 'Connection error, try again', vn: 'Lỗi kết nối, thử lại sau' },
        'pw.success':         { en: 'Password changed successfully', vn: 'Đổi mật khẩu thành công' },

        // ── Common ──
        'common.edit':        { en: 'Edit',             vn: 'Sửa' },
        'common.delete':      { en: 'Delete',           vn: 'Xóa' },
        'common.cancel':      { en: 'Cancel',           vn: 'Hủy' },
        'common.save':        { en: 'Save',             vn: 'Lưu' },
        'common.verified':    { en: 'Verified',         vn: 'Xác minh' },
        'common.unverified':  { en: 'Unverified',       vn: 'Chưa xác minh' },
        'common.followers':   { en: 'followers',        vn: 'người theo dõi' },
        'common.plays':       { en: 'plays',            vn: 'lượt phát' },
        'common.no_data':     { en: 'No data',          vn: 'Không có dữ liệu' },
        'login.username_ph':  { en: 'Enter username',   vn: 'Nhập tên đăng nhập' },
        'login.password_ph':  { en: 'Enter password',   vn: 'Nhập mật khẩu' },
        'login.btn':          { en: 'Login',             vn: 'Đăng nhập' },
        'login.logging_in':   { en: 'Logging in...',    vn: 'Đang đăng nhập...' },
        'login.err_fill':     { en: 'Please enter credentials', vn: 'Vui lòng nhập đầy đủ thông tin' },
    };

    let _lang = localStorage.getItem(LANG_KEY) || 'vn';

    // ── Get translation ──
    function t(key, vars = {}) {
        const entry = dict[key];
        if (!entry) return key;
        let str = entry[_lang] || entry['en'] || key;
        // Replace {var} placeholders
        Object.entries(vars).forEach(([k, v]) => {
            str = str.replace(new RegExp(`\\{${k}\\}`, 'g'), v);
        });
        return str;
    }

    // ── Current lang ──
    function lang() { return _lang; }

    // ── Apply translations to DOM via data-i18n ──
    function apply() {
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            const attr = el.getAttribute('data-i18n-attr'); // e.g. "placeholder"
            const val = t(key);
            if (attr) {
                el.setAttribute(attr, val);
            } else {
                el.innerHTML = val;
            }
        });
        // Update lang button label
        const btn = document.getElementById('lang-btn-label');
        if (btn) btn.textContent = _lang === 'en' ? 'VN' : 'EN';
    }

    // ── Toggle EN ↔ VN ──
    function toggle() {
        _lang = _lang === 'en' ? 'vn' : 'en';
        localStorage.setItem(LANG_KEY, _lang);
        apply();
        // Re-render current page
        _reRenderCurrentPage();
    }

    function _reRenderCurrentPage() {
        const active = document.querySelector('.page.active');
        if (!active) return;
        const pageId = active.id.replace('page-', '');
        if (pageId === 'overview')      renderOverview();
        else if (pageId === 'songs')    renderSongs();
        else if (pageId === 'artists')  renderArtists();
        else if (pageId === 'users')    renderUsers();
        else if (pageId === 'analytics') renderAnalytics();
        // Update page title/subtitle via navigation keys
        const titleEl = document.getElementById('page-title');
        const subEl   = document.getElementById('page-subtitle');
        if (titleEl && dict[`page.${pageId}.title`]) titleEl.textContent = t(`page.${pageId}.title`);
        if (subEl   && dict[`page.${pageId}.sub`])   subEl.textContent   = t(`page.${pageId}.sub`);
    }

    function init() {
        _lang = localStorage.getItem(LANG_KEY) || 'vn';
    }

    return { t, lang, apply, toggle, init };
})();
