// Search functionality
function searchSongs(query) {
    if (!query) {
        renderSongs(DATA.songs);
        return;
    }

    const q = query.toLowerCase();
    const filtered = DATA.songs.filter(s =>
        (s.title && s.title.toLowerCase().includes(q)) ||
        (s.full_name && s.full_name.toLowerCase().includes(q))
    );
    renderSongs(filtered);
}