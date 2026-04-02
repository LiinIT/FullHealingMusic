// Render Artists page
function renderArtists() {
    const grid = document.getElementById('artists-grid');
    if (grid && DATA.artists) {
        grid.innerHTML = DATA.artists.map(a => `
            <div class="artist-card" onclick="showToast('👤 Xem hồ sơ: ${a.name}', 'info')">
                <div class="artist-avatar">${a.icon}</div>
                <div class="artist-name">${escapeHtml(a.name)}</div>
                <div class="artist-songs">${a.songs} bài hát</div>
                <div class="artist-followers">${a.followers} followers</div>
            </div>
        `).join('');
    }

    const tbody = document.getElementById('albums-tbody');
    if (tbody && DATA.albums) {
        tbody.innerHTML = DATA.albums.map(a => `
            <tr>
                <td>
                    <div class="song-row">
                        <div class="song-thumb">${a.icon}</div>
                        <div>
                            <div class="song-name">${escapeHtml(a.name)}</div>
                            <div class="song-artist">${a.year}</div>
                        </div>
                    </div>
                </td>
                <td>${escapeHtml(a.artist)}</td>
                <td>${a.songs} tracks</td>
                <td>${a.plays}</td>
                <td>
                    <div class="action-btns">
                        <button class="btn-sm btn-view" onclick="showToast('Album: ${a.name}', 'info')">${ICONS.ui.view} View</button>
                        <button class="btn-sm btn-edit" onclick="showToast('Editing...', 'info')">${ICONS.ui.edit} Edit</button>
                    </div>
                </td>
            </tr>
        `).join('');
    }
}