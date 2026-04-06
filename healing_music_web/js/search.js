// Search functionality
function searchSongs() {
    const value = document.getElementById('songs-search').value;

    console.log(value);

    if (!value) {
        renderSongs(DATA.songs);
        return;
    }

    const q = value.toLowerCase();
    const filtered = DATA.songs.filter(s =>
        (s.title && s.title.toLowerCase().includes(q)) ||
        (s.full_name && s.full_name.toLowerCase().includes(q))
    );
    renderSongs(filtered);
};