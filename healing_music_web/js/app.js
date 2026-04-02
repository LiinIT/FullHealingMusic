// Main initialization
document.addEventListener('DOMContentLoaded', async () => {
    // === THÊM ĐOẠN NÀY: Load HTML components ===
    await HTML_LOADER.loadAll();
    // === KẾT THÚC ===

    // Update topbar icons
    const searchBtn = document.querySelector('.topbar-search button');
    if (searchBtn) searchBtn.innerHTML = ICONS.ui.search;

    const bellBtn = document.querySelector('.topbar-actions .icon-btn:nth-child(1)');
    if (bellBtn) bellBtn.innerHTML = ICONS.ui.bell;

    const themeBtn = document.querySelector('.topbar-actions .icon-btn:nth-child(2)');
    if (themeBtn) themeBtn.innerHTML = ICONS.ui.moon;

    const userBtn = document.querySelector('.topbar-actions .icon-btn:nth-child(3)');
    if (userBtn) userBtn.innerHTML = ICONS.ui.user;

    // Load data from API
    await loadSongsFromAPI();

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
                searchSongs(q);
            } else {
                renderSongs(DATA.songs);
            }
        });
    }

    // Page song search
    const songsSearch = document.getElementById('songs-search');
    if (songsSearch) {
        songsSearch.addEventListener('input', e => searchSongs(e.target.value));
    }

    // Close modal on overlay click
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => {
            if (e.target === overlay) overlay.classList.remove('show');
        });
    });
});