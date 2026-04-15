// Navigation
async function navigate(pageId) {
    // Cập nhật active class cho nav items
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll(`[data-page="${pageId}"]`).forEach(n => n.classList.add('active'));

    // Load page tương ứng
    await HTML_LOADER.loadPage(pageId, `pages/${pageId}.html`);

    // Cập nhật title
    const titles = {
        overview: ['Overview', 'Tổng quan hệ thống'],
        songs: ['Songs', 'Quản lý bài hát'],
        artists: ['Artists & Albums', 'Quản lý nghệ sĩ & album'],
        users: ['Users & Playlists', 'Quản lý người dùng'],
        notifications: ['Notifications', 'Quản lý thông báo push'],
        settings: ['Settings', 'Chính sách & nội dung hệ thống'],
    };
    const t = titles[pageId] || ['Dashboard', ''];
    document.getElementById('page-title').textContent = t[0];
    document.getElementById('page-subtitle').textContent = t[1];

    // Gọi render sau khi load xong
    if (pageId === 'overview') renderOverview();
    else if (pageId === 'songs') renderSongs();
    else if (pageId === 'artists') renderArtists();
    else if (pageId === 'users') renderUsers();
    else if (pageId === 'notifications') renderNotifications();
    // settings page is static, no render needed
}