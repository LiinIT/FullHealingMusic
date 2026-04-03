function renderArtists() {
    const grid = document.getElementById('artists-grid');
    if (grid && Array.isArray(DATA.artists)) {
        grid.innerHTML = '';  // Clear any existing content first
        DATA.artists.forEach(a => {
            const artistCard = document.createElement('div');
            artistCard.className = 'artist-card';
            artistCard.onclick = () => showToast('👤 ' + escapeHtml(a.full_name), 'info');

            const avatar = a.avatar_url || 'https://via.placeholder.com/40';
            artistCard.innerHTML = `
                <div class="artist-avatar" style="background-image: url('${avatar}')"></div>
                <div class="artist-name">${escapeHtml(a.full_name || 'Unknown')}</div>
                <div class="artist-songs">${(Array.isArray(DATA.songs) ? DATA.songs.filter(s => s.artist_id === a.id).length : 0)} bài hát</div>
                <div class="artist-followers">${a.follower_count ?? 0} followers</div>
            `;
            grid.appendChild(artistCard);
        });
    }

    // ─── ALBUMS ─────────────────────
    const tbody = document.getElementById('albums-tbody');
    if (tbody && Array.isArray(DATA.albums)) {
        tbody.innerHTML = '';  // Clear existing content
        DATA.albums.forEach(a => {
            const row = document.createElement('tr');
            const coverUrl = a.cover_url || 'https://via.placeholder.com/40';
            row.innerHTML = `
                <td>
                    <div class="song-row">
                        <div style="display: flex;"> 
                            <div class="artist-avatar" style="background-image: url('${coverUrl}')"></div>
                            <div  style="display: flex;flex-direction: column;justify-content: center;padding-left: 2em;">
                                <div class="song-name">${escapeHtml(a.title || 'No title')}</div>
                                <div class="song-artist">${a.album_type || 'album'}</div>
                            </div>
                        </div>
                    </div>
                </td>
                <td>${escapeHtml(a.artist?.full_name || 'Unknown')}</td>
                <td>${a.total_songs ?? 0} tracks</td>
                <td>-</td>
                <td>
                    <div class="action-btns">
                        <button class="btn-sm btn-view" onclick="viewAlbum(${a.id})">${ICONS.ui.view} View</button>
                        <button class="btn-sm btn-edit" onclick="openEditAlbum(${a.id})">${ICONS.ui.edit} Edit</button>
                        <button class="btn-sm btn-del" onclick="deleteAlbum(${a.id})">${ICONS.ui.delete} Delete</button>
                    </div>
                </td>
            `;
            tbody.appendChild(row);
        });
    }
}

async function addArtist() {
    const btn = event?.target;

    const fullName = document.getElementById('new-artist-name')?.value?.trim();
    const bio = document.getElementById('new-artist-bio')?.value?.trim();

    if (!fullName) {
        showToast('⚠️ Tên nghệ sĩ là bắt buộc', 'error');
        return;
    }

    const fileImage = selectedFiles.artist.image;
    let imageUrl = null;
    if (fileImage) imageUrl = await uploadFile(fileImage);

    try {
        btn?.setAttribute('disabled', true);

        const { success, data } = await postAPI('/artists/crud_artist', {
            action: 'addArtist',
            fullName,
            avatarUrl: imageUrl || 'https://i.pravatar.cc/150',
            bio: bio || '',
        });

        if (success && data.done) {
            showToast(`✅ Thêm nghệ sĩ thành công!`, 'success');
            // reset form
            document.getElementById('new-artist-name').value = '';
            document.getElementById('artist-image-preview').value = '';
            document.getElementById('new-artist-bio').value = '';

            closeModal('modal-add-artist');

            await loadArtistFromAPI();

        } else {
            showToast(`❌ ${data?.message ?? 'Thêm thất bại'}`, 'error');
        }

    } catch (e) {
        console.error(e);
        showToast(`❌ Đã có vấn đề gì đó xảy ra!!!`, 'error');
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

    const { success, data } = await postAPI('/artists/album', {
        action: 'addAlbum',
        artistId: parseInt(artistId),
        title, albumType,
        coverUrl: coverUrl || null,
    });

    if (success && data.done) {
        console.log(data)
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
