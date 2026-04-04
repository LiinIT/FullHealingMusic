// Render Users page
function renderUsers() {
    const tbody = document.getElementById('users-tbody');
    if (tbody && DATA.users) {
        tbody.innerHTML = DATA.users.map(u => `
            <tr>
                <td>
                    <div class="song-row">
                        <div style="display: flex;"> 
                            <div class="artist-avatar" style="background-image: url('${u.avatar_url || ''}')"></div>
                            <div  style="display: flex;flex-direction: column;justify-content: center;padding-left: 2em;">
                                <div class="song-name">${escapeHtml(u.full_name || 'Unknown')}</div>
                                <div class="song-artist">@${u.username || 'Unknown'}</div>
                            </div>
                        </div>
                    </div>
                </td>
                <td>${escapeHtml(u.email || 'Unknown')}</td>
                <td>${u.role}</td>
                <td>
                    <div class="action-btns">
                        <button class="btn-sm btn-view" onclick="viewAlbum(${u.id})">${ICONS.ui.view} View</button>
                        <button class="btn-sm btn-edit" onclick="openEditAlbum(${u.id})">${ICONS.ui.edit} Edit</button>
                        <button class="btn-sm btn-del" onclick="deleteAlbum(${u.id})">${ICONS.ui.delete} Delete</button>
                    </div>
                </td>
            </tr>
        `).join('');
    }

    const pgrid = document.getElementById('playlists-grid');
    if (pgrid && DATA.playlists) {
        pgrid.innerHTML = DATA.playlists.map(p => `
            <div class="playlist-card">
                <div class="playlist-cover">
                    <span style="position:relative;z-index:1;font-size:36px">${p.icon}</span>
                    <div class="playlist-cover-overlay"></div>
                </div>
                <div class="playlist-info">
                    <div class="playlist-name">${escapeHtml(p.name)}</div>
                    <div class="playlist-meta">
                        <span><i class="fa-brands fa-soundcloud"></i> ${p.songs}</span>
                        <span>${p.visibility === 'public' ? '<i class="fa-solid fa-globe"></i>' : '<i class="fa-solid fa-lock"></i>'} ${p.visibility}</span>
                    </div>
                    <div style="font-size:11px;color:var(--text-muted);margin-top:5px">${p.user}</div>
                </div>
            </div>
        `).join('');
    }
}


// ─── DELETE USER ─────────────────────────────────────────────────────────────
function deleteUser(id) {
    if (!confirm('Bạn có chắc muốn ban user này?')) return;
    const idx = DATA.users.findIndex(x => x.id === id);
    if (idx > -1) {
        DATA.users.splice(idx, 1);
        renderUsers();
        showToast('🚫 User đã bị ban', 'error');
    }
}


function openEdirUser(id) {
    const s = DATA.songs.find(x => x.song_id === id);
    if (!s) return;

    const modal = document.getElementById('modal-confirm-delete');
    modal.setAttribute('data-song-id', id);
    document.getElementById('delete-message').textContent =
        `Bạn có chắc muốn xoá "${s.title}"?`;
    document.getElementById('btn-confirm-del').setAttribute('onClick', 'deleteSong()');

    openModal('modal-confirm-delete');
}