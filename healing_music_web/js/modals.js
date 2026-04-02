// Modal handling
function openModal(id) {
    document.getElementById(id)?.classList.add('show');
}

function closeModal(id) {
    document.getElementById(id)?.classList.remove('show');
}

function editSong(id) {
    const s = DATA.songs.find(x => x.song_id === id);
    if (!s) return;

    const titleInput = document.getElementById('edit-song-title');
    const artistInput = document.getElementById('edit-song-artist');
    if (titleInput) titleInput.value = s.title || '';
    if (artistInput) artistInput.value = s.full_name || '';

    openModal('modal-edit-song');
}

function deleteSong(id) {
    if (!confirm('Bạn có chắc muốn xóa bài hát này?')) return;

    const idx = DATA.songs.findIndex(x => x.song_id === id);
    if (idx > -1) {
        DATA.songs.splice(idx, 1);
        renderSongs();
        showToast('Bài hát đã được xóa', 'error');
    }
}

function deleteUser(id) {
    if (!confirm('Bạn có chắc muốn ban user này?')) return;

    const idx = DATA.users.findIndex(x => x.id === id);
    if (idx > -1) {
        DATA.users.splice(idx, 1);
        renderUsers();
        showToast('User đã bị ban', 'error');
    }
}

function saveEditSong() {
    showToast('Cập nhật bài hát thành công!', 'success');
    closeModal('modal-edit-song');
}

function saveNewSong() {
    const title = document.getElementById('new-song-title')?.value;
    const artist = document.getElementById('new-song-artist')?.value;

    if (!title || !artist) {
        showToast('Vui lòng điền đầy đủ thông tin', 'error');
        return;
    }

    const newSong = {
        song_id: Date.now(),
        title: title,
        full_name: artist,
        rank: DATA.songs.length + 1,
        play_count: 0,
        duration_seconds: 0,
        image_url: '',
        icon: getSongIcon({ title, artist })
    };

    DATA.songs.unshift(newSong);
    renderSongs();
    closeModal('modal-add-song');
    showToast('Thêm bài hát thành công!', 'success');

    // Clear form
    document.getElementById('new-song-title').value = '';
    document.getElementById('new-song-artist').value = '';
}

function saveNewArtist() {
    const name = document.getElementById('new-artist-name')?.value;
    if (!name) {
        showToast('Nhập tên nghệ sĩ', 'error');
        return;
    }

    const newArtist = {
        id: Date.now(),
        name: name,
        followers: '0',
        songs: 0,
        streams: '0',
        icon: getArtistIcon({ name })
    };

    DATA.artists.unshift(newArtist);
    renderArtists();
    closeModal('modal-add-artist');
    showToast('Thêm nghệ sĩ thành công!', 'success');
}