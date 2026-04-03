// Render Songs page
function renderSongs(songs = DATA.songs) {

    const tbody = document.getElementById('songs-tbody');

    if (!tbody) return;

    // Sort by play count
    const isort = [...songs].sort((a, b) => (b.play_count || 0) - (a.play_count || 0));

    tbody.innerHTML = isort.map(s => `
        <tr>
            <td>${s.play_count || '—'}</td>
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
                    <button class="btn-sm btn-edit" onclick="openEditSong(${s.song_id})">${ICONS.ui.edit} Edit</button>
                    <button class="btn-sm btn-del" onclick="openDeleteSong(${s.song_id})">${ICONS.ui.delete} Del</button>
                </div>
            </td>
        </tr>
    `).join('');
}


async function openAddSongModal() {
    resetAddSongForm();
    const select = document.getElementById('new-song-artist-id');
    if (select) loadOptionArtist(select);
    openModal('modal-add-song');
}
// ─── ADD SONG ────────────────────────────────────────────────────────────────
async function addSong() {
    const title = document.getElementById('new-song-title')?.value?.trim();
    const artistId = document.getElementById('new-song-artist-id')?.value;
    const duration = document.getElementById('new-song-duration')?.value;

    const fileAudio = selectedFiles.create.audio;
    const fileImage = selectedFiles.create.image;

    if (!title) return showToast('Thiếu title', 'error');
    if (!artistId) return showToast('Thiếu artist', 'error');
    if (!fileAudio) return showToast('Thiếu audio', 'error');

    const audioUrl = await uploadFile(fileAudio);
    if (!audioUrl) return;

    let imageUrl = null;
    if (fileImage) imageUrl = await uploadFile(fileImage);

    const { success, data } = await postAPI('/songs/crud_song', {
        action: 'addSong',
        title,
        artistId: parseInt(artistId),
        audioUrl,
        imageUrl,
        durationSeconds: duration ? parseInt(duration) : null,
    });

    if (success && data.done) {
        closeModal('modal-add-song');
        selectedFiles.create = { audio: null, image: null };
        await loadSongsFromAPI();
    }
}

// ─── OPEN EDIT SONG ──────────────────────────────────────────────────────────
function openEditSong(id) {
    const s = DATA.songs.find(x => x.song_id === id);
    if (!s) return;

    loadOptionArtist(document.getElementById('edit-song-artist-id'));

    document.getElementById('modal-edit-song').setAttribute('data-song-id', id);
    document.getElementById('edit-song-title').value = s.title || '';
    document.getElementById('edit-song-artist-id').value = s.artist_id || '';
    document.getElementById('edit-song-duration').value = s.duration_seconds || '';

    const audioPreview = document.getElementById('edit-audio-preview');
    const audioFilename = document.getElementById('edit-audio-filename');

    if (audioPreview && s.audio_url) {
        audioPreview.src = s.audio_url;
        audioPreview.style.display = 'block';
        audioFilename.textContent = s.audio_url.split('/').pop();
    }

    const imgPreview = document.getElementById('edit-image-preview');
    const imgFilename = document.getElementById('edit-image-filename');

    if (imgPreview && s.image_url) {
        imgPreview.src = s.image_url;
        imgPreview.style.display = 'block';
        imgFilename.textContent = s.image_url.split('/').pop();
    }

    file_song = null;
    file_img = null;

    openModal('modal-edit-song');
}

// ─── EDIT SONG ───────────────────────────────────────────────────────────────
async function editSong() {
    const songId = parseInt(
        document.getElementById('modal-edit-song').getAttribute('data-song-id')
    );

    const title = document.getElementById('edit-song-title')?.value?.trim();
    const artistId = document.getElementById('edit-song-artist-id')?.value;
    const duration = document.getElementById('edit-song-duration')?.value;

    const currentSong = DATA.songs.find(x => x.song_id === songId);

    let audioUrl = currentSong?.audio_url;
    let imageUrl = currentSong?.image_url;

    if (selectedFiles.edit.audio) {
        audioUrl = await uploadFile(selectedFiles.edit.audio);
    }

    if (selectedFiles.edit.image) {
        imageUrl = await uploadFile(selectedFiles.edit.image);
    }

    const { success, data } = await postAPI('/songs/crud_song', {
        action: 'update',
        songID: songId,
        title,
        artistId: parseInt(artistId),
        audioUrl,
        imageUrl,
        durationSeconds: duration ? parseInt(duration) : null,
    });

    if (success && data.done) {
        closeModal('modal-edit-song');
        selectedFiles.edit = { audio: null, image: null };
        await loadSongsFromAPI();
    }
}

// ─── DELETE SONG ─────────────────────────────────────────────────────────────
function openDeleteSong(id) {
    const s = DATA.songs.find(x => x.song_id === id);
    if (!s) return;

    const modal = document.getElementById('modal-confirm-delete');
    modal.setAttribute('data-song-id', id);
    document.getElementById('delete-message').textContent =
        `Bạn có chắc muốn xoá "${s.title}"?`;

    openModal('modal-confirm-delete');
}

async function deleteSong() {
    const songId = parseInt(
        document.getElementById('modal-confirm-delete').getAttribute('data-song-id')
    );

    const { success, data } = await postAPI('/songs/crud_song', {
        action: 'delete',
        songID: songId,
    });

    if (!success || !data.done) {
        showToast('❌ Xoá thất bại', 'error');
        return;
    }

    showToast('${ICONS.ui.delete} Đã xoá', 'success');
    closeModal('modal-confirm-delete');
    await loadSongsFromAPI();
}