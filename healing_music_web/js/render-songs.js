// Render Songs page
function renderSongs(songs = DATA.songs) {
    const tbody = document.getElementById('songs-tbody');

    // Update count
    const songsCount = document.getElementById('songs-count');
    const isongCount = document.getElementById('isong-count');
    if (songsCount) songsCount.innerText = `${songs.length} bài hát`;
    if (isongCount) isongCount.innerText = `${songs.length}`;

    if (!tbody) return;

    // Sort by play count
    const isort = [...songs].sort((a, b) => (b.play_count || 0) - (a.play_count || 0));

    tbody.innerHTML = isort.map(s => `
        <tr>
            <td>${s.rank || '—'}</td>
            <td>
                <div class="song-row">
                    <img src="${s.image_url || ''}" width="40" height="40" style="border-radius: 8px;">
                    <div>
                        <div class="song-name">${escapeHtml(s.title)}</div>
                        <div class="song-artist">${escapeHtml(s.full_name)}</div>
                    </div>
                </div>
            </td>
            <td>${formatDuration(s.duration_seconds)}</td>
            <td>
                <div class="action-btns">
                    <button class="btn-sm btn-edit" onclick="editSong(${s.song_id})">${ICONS.ui.edit} Edit</button>
                    <button class="btn-sm btn-del" onclick="deleteSong(${s.song_id})">${ICONS.ui.delete} Del</button>
                </div>
            </td>
        </tr>
    `).join('');
}