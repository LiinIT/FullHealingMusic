// ─── SONGS SEARCH (songs page only) ─────────────────────────────────────────
let _songSearchSeq = 0;

async function searchSongs(idInput) {
    const value = document.getElementById(idInput)?.value?.trim();
    const seq = ++_songSearchSeq;

    if (!value) {
        if (DATA.songs && DATA.songs.length > 0) {
            renderSongs(DATA.songs);
        } else {
            await loadSongsFromAPI();
        }
        return;
    }

    const { success, data } = await postAPI('/songs/search', { keyword: value });
    if (seq !== _songSearchSeq) return; // bỏ kết quả cũ nếu đã có request mới hơn
    if (success && data.songs) {
        renderSongs(data.songs);
    } else {
        renderSongs([]);
    }
}
