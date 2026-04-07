// Search functionality
function searchSongs(idInput) {
    const value = document.getElementById(idInput).value;

    if (!value) {
        renderSongs(DATA.songs);
        return;
    }

    const filtered = DATA.songs.filter(s =>
        (s.title && s.title.toLowerCase().includes(value.toLowerCase())) ||
        (s.full_name && s.full_name.toLowerCase().includes(value.toLowerCase()))
    );
    renderSongs(filtered);
};