function renderArtists() {
    const grid = document.getElementById('artists-grid');

    // ─── ARTISTS ─────────────────────
    if (grid && Array.isArray(DATA.artists)) {
        grid.innerHTML = DATA.artists.map(a => `
            <div class="artist-card"
                 onclick="showToast('👤 ${escapeHtml(a.full_name)}', 'info')">

                <div class="artist-avatar">
                    <img src="${a.avatar_url || 'https://via.placeholder.com/40'}"
                         width="40" height="40">
                </div>

                <div class="artist-name">
                    ${escapeHtml(a.full_name || 'Unknown')}
                </div>

                <div class="artist-songs">
                    ${a.song_count ?? 0} bài hát
                </div>

                <div class="artist-followers">
                    ${a.follower_count ?? 0} followers
                </div>
            </div>
        `).join('');
    }

    // ─── ALBUMS ─────────────────────
    const tbody = document.getElementById('albums-tbody');

    if (tbody && Array.isArray(DATA.albums)) {
        tbody.innerHTML = DATA.albums.map(a => `
            <tr>
                <td>
                    <div class="song-row">
                        <div class="song-thumb">
                            <img src="${a.cover_url || 'https://via.placeholder.com/40'}"
                                 width="40" height="40">
                        </div>

                        <div>
                            <div class="song-name">
                                ${escapeHtml(a.title || 'No title')}
                            </div>

                            <div class="song-artist">
                                ${a.album_type || 'album'}
                            </div>
                        </div>
                    </div>
                </td>

                <td>
                    ${escapeHtml(a.artist?.full_name || 'Unknown')}
                </td>

                <td>
                    ${a.total_songs ?? 0} tracks
                </td>

                <td>-</td>

                <td>
                    <div class="action-btns">

                        <button class="btn-sm btn-view"
                            onclick="viewAlbum(${a.id})">
                            ${ICONS.ui.view} View
                        </button>

                        <button class="btn-sm btn-edit"
                            onclick="openEditAlbum(${a.id})">
                            ${ICONS.ui.edit} Edit
                        </button>

                        <button class="btn-sm btn-danger"
                            onclick="deleteAlbum(${a.id})">
                            🗑 Delete
                        </button>

                    </div>
                </td>
            </tr>
        `).join('');
    }
}

async function addArtist() {
    const btn = event?.target;

    const fullName = document.getElementById('new-artist-name')?.value?.trim();
    const avatarUrl = document.getElementById('new-artist-avatar')?.value?.trim();
    const bio = document.getElementById('new-artist-bio')?.value?.trim();

    if (!fullName) {
        showToast('⚠️ Tên nghệ sĩ là bắt buộc', 'error');
        return;
    }

    try {
        btn?.setAttribute('disabled', true);

        const { success, data } = await postAPI('/artists/manage', {
            action: 'addArtist',
            fullName,
            avatarUrl: avatarUrl || 'https://i.pravatar.cc/150',
            bio: bio || '',
        });

        if (success && data.done) {
            showToast(`✅ Thêm nghệ sĩ thành công!`, 'success');

            // reset form
            document.getElementById('new-artist-name').value = '';
            document.getElementById('new-artist-avatar').value = '';
            document.getElementById('new-artist-bio').value = '';

            closeModal('modal-add-artist');

            await loadArtistFromAPI();

        } else {
            showToast(`❌ ${data?.message ?? 'Thêm thất bại'}`, 'error');
        }

    } catch (e) {
        console.error(e);
        showToast('❌ Lỗi server', 'error');
    } finally {
        btn?.removeAttribute('disabled');
    }
}


// ─── ADD ALBUM ───────────────────────────────────────────────────────────────
async function addAlbum() {
    const title = document.getElementById('new-album-title')?.value?.trim();
    const artistId = document.getElementById('new-album-artist-id')?.value?.trim();
    const albumType = document.getElementById('new-album-type')?.value ?? 'album';
    const coverUrl = document.getElementById('new-album-cover')?.value?.trim();

    if (!title || !artistId) {
        showToast('⚠️ Tên album và Artist ID là bắt buộc', 'error');
        return;
    }

    const { success, data } = await postAPI('/artist_albums', {
        action: 'addAlbum',
        artistId: parseInt(artistId),
        title, albumType,
        coverUrl: coverUrl || null,
    });

    if (success && data.done) {
        showToast(`✅ Thêm album thành công! ID: ${data.id}`, 'success');
        closeModal('modal-add-album');
        await loadAlbumFromAPI();
    } else {
        showToast(`❌ ${data?.message ?? 'Thêm thất bại'}`, 'error');
    }
}

// ─── ADD SONG TO ALBUM ───────────────────────────────────────────────────────
async function addSongToAlbum(albumId, songId, trackNumber = 999) {
    const { success, data } = await postAPI('/artist_albums', {
        action: 'addSongToAlbum',
        albumId, songId, trackNumber,
    });
    if (success && data.done) {
        showToast('✅ Đã thêm bài hát vào album', 'success');
    } else {
        showToast(`❌ ${data?.message ?? 'Thất bại'}`, 'error');
    }
}
