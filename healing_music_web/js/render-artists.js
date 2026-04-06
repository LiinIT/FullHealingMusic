function renderArtists() {
    const grid = document.getElementById('artists-grid');
    let countAlbum = 0;
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
                <div class="artist-songs">
                    ${(Array.isArray(DATA.songs) ?
                    DATA.songs.filter(s => s.artist_id === a.id).length :
                    0)} bài hát 
                    ·
                    ${Array.isArray(DATA.albums)
                    ? DATA.albums.filter(s => s.artist_id === a.id).length
                    : 0} albums
                        
                </div>
                <div class="artist-followers">${a.follower_count ?? 0} followers</div>
                <div class="btn-del" onClick="openDeleteArtist(${a.id})" style="margin-top:2em; padding: 0.4em"><i class="fa-solid fa-ban"></i> Ban</div>
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
                        <button class="btn-sm btn-del" onclick="openDeleteAlbum(${a.id})">${ICONS.ui.delete} Delete</button>
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
            selectedFiles.artist = { audio: null, image: null };
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

async function openDeleteArtist(id) {
    const a = DATA.artists.find(x => x.id === id);
    if (!a) return;

    const modal = document.getElementById('modal-confirm-delete');
    modal.setAttribute('data-artist-id', id);
    document.getElementById('delete-message').textContent =
        `Bạn có chắc muốn xoá "${a.full_name}"?`;

    document.getElementById('btn-confirm-del').setAttribute('onClick', 'deleteArtist()');

    openModal('modal-confirm-delete');
}

async function deleteArtist() {
    const artistID = parseInt(
        document.getElementById('modal-confirm-delete').getAttribute('data-artist-id')
    );

    const { success, data } = await postAPI('/artists/crud_artist', {
        action: 'deleteArtist',
        artistId: artistID,
    });

    if (!success || !data.done) {
        showToast('❌ Xoá thất bại', 'error');
        return;
    }

    showToast('<i class="fa-solid fa-ban"></i> Đã Ban', 'success');
    closeModal('modal-confirm-delete');
    await loadArtistFromAPI();
}

// ─── ADD ALBUM ───────────────────────────────────────────────────────────────
async function openAddAlbum() {
    resetAddSongForm();
    const select = document.getElementById('new-album-artist-id');
    if (select) loadOptionArtist(select);
    document.getElementById('btn-album-action').setAttribute('onClick', 'addAlbum()');
    openModal('modal-add-album');
}

async function openEditAlbum(id) {
    const album = DATA.albums.find(al => al.id == id);
    const select = document.getElementById('edit-album-artist-id');
    if (select) loadOptionArtist(select);

    document.getElementById('modal-edit-album').setAttribute('edit-album-artist-id', id);
    document.getElementById('edit-album-artist-id').value = album.artist_id;
    document.getElementById('edit-album-title').value = album.title;
    document.getElementById('edit-album-type').value = album.album_type;
    document.getElementById('btn-album-action').setAttribute('onClick', `updateAlbum(${id})`);

    openModal('modal-edit-album');
}

async function addAlbum() {
    const title = document.getElementById('new-album-title')?.value?.trim();
    const artistId = document.getElementById('new-album-artist-id')?.value?.trim();
    const albumType = document.getElementById('new-album-type')?.value ?? 'album';
    const fileImage = selectedFiles.album.image;

    if (!title || !artistId) {
        showToast('⚠️ Tên album và Artist ID là bắt buộc', 'error');
        return;
    }

    let imageUrl = null;
    if (fileImage) imageUrl = await uploadFile(fileImage);

    const { success, data } = await postAPI('/artists/album', {
        action: 'addAlbum',
        artistId: parseInt(artistId),
        title, albumType,
        coverUrl: imageUrl || null,
    });

    if (success && data.done) {
        selectedFiles.album = { audio: null, image: null };
        showToast(`✅ Thêm album thành công! ID: ${data.id}`, 'success');
        closeModal('modal-add-album');
        await loadArtistFromAPI();
    } else {
        showToast(`❌ ${data?.message ?? 'Thêm thất bại'}`, 'error');
    }
}

async function updateAlbum(id) {
    const title = document.getElementById('edit-album-title')?.value?.trim();
    const artistId = document.getElementById('edit-album-artist-id')?.value?.trim();
    const albumType = document.getElementById('edit-album-type')?.value ?? 'album';
    const image = document.getElementById('album-image-preview')?.value;
    let imageUrl = null;

    if (image == null) {
        const album = DATA.albums.find(al => al.id == id);
        imageUrl = album.cover_url;
    } else {
        const fileImage = selectedFiles.album.image;
        if (fileImage) imageUrl = await uploadFile(fileImage);
    }

    if (!title || !artistId) {
        showToast('⚠️ Tên album và Artist ID là bắt buộc', 'error');
        return;
    }

    const { success, data } = await postAPI('/artists/album', {
        action: 'updateAlbum',
        albumId: parseInt(id),
        artistId: parseInt(artistId),
        title,
        albumType,
        coverUrl: imageUrl || null,
    });

    if (success && data.done) {
        selectedFiles.album = { audio: null, image: null };
        showToast(`✅ Thêm album thành công! ID: ${data.id}`, 'success');
        closeModal('modal-edit-album');
        await loadArtistFromAPI();
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

async function openDeleteAlbum(id) {
    const a = DATA.albums.find(x => x.id === id);
    if (!a) return;

    const modal = document.getElementById('modal-confirm-delete');
    modal.setAttribute('data-album-id', id);
    document.getElementById('delete-message').textContent =
        `Bạn có chắc muốn xoá "${a.title}"?`;

    document.getElementById('btn-confirm-del').setAttribute('onClick', 'deleteAlbum()');

    openModal('modal-confirm-delete');
}

async function deleteAlbum() {
    const albumId = parseInt(
        document.getElementById('modal-confirm-delete').getAttribute('data-album-id')
    );

    const { success, data } = await postAPI('/artists/album', {
        action: 'deleteAlbum',
        albumId: albumId,
    });

    if (!success || !data.done) {
        showToast('❌ Xoá thất bại', 'error');
        return;
    }

    showToast('<i class="fa-solid fa-ban"></i> Đã xóa', 'success');
    closeModal('modal-confirm-delete');

    await renderArtists(DATA.albums);
}