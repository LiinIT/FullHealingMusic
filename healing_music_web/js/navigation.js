// Navigation
function navigate(pageId) {
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.getElementById('page-' + pageId)?.classList.add('active');
    document.querySelectorAll(`[data-page="${pageId}"]`).forEach(n => n.classList.add('active'));

    const titles = {
        overview: ['Overview', 'Tổng quan hệ thống'],
        songs: ['Songs', 'Quản lý bài hát'],
        artists: ['Artists & Albums', 'Quản lý nghệ sĩ & album'],
        users: ['Users & Playlists', 'Quản lý người dùng'],
    };
    const t = titles[pageId] || ['Dashboard', ''];
    document.getElementById('page-title').textContent = t[0];
    document.getElementById('page-subtitle').textContent = t[1];
}