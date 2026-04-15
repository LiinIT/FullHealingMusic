// Navigation
async function navigate(pageId) {
    // Cập nhật active class cho nav items
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll(`[data-page="${pageId}"]`).forEach(n => n.classList.add('active'));

    // Load page tương ứng
    await HTML_LOADER.loadPage(pageId, `pages/${pageId}.html`);

    // Cập nhật title
    const titleEl = document.getElementById('page-title');
    const subEl   = document.getElementById('page-subtitle');
    if (titleEl) titleEl.textContent = I18N.t(`page.${pageId}.title`) !== `page.${pageId}.title` ? I18N.t(`page.${pageId}.title`) : pageId;
    if (subEl)   subEl.textContent   = I18N.t(`page.${pageId}.sub`)   !== `page.${pageId}.sub`   ? I18N.t(`page.${pageId}.sub`)   : '';

    // Gọi render sau khi load xong
    if (pageId === 'overview') renderOverview();
    else if (pageId === 'songs') renderSongs();
    else if (pageId === 'artists') renderArtists();
    else if (pageId === 'users') renderUsers();
    else if (pageId === 'notifications') renderNotifications();
    else if (pageId === 'analytics') renderAnalytics();
    // settings page is static, no render needed
}