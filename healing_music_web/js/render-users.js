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
                        <button class="btn-sm btn-view" onclick="viewUser('${u.id}')">${ICONS.ui.view} View</button>
                        <button class="btn-sm btn-edit" onclick="openEdirUser('${u.id}')">${ICONS.ui.edit} Edit</button>
                        <button class="btn-sm btn-del" onclick="deleteUser('${u.id}')">${ICONS.ui.delete} Delete</button>
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


// ─── ADD USER ─────────────────────────────────────────────────────────────
async function addUser() {
    try {
        const username = document.getElementById('new-user-acc')?.value;
        const password = document.getElementById('new-user-pass')?.value;
        const userTag = document.getElementById('new-user-tag')?.value;
        const fullName = document.getElementById('new-user-name')?.value.trim();
        const email = document.getElementById('new-user-email')?.value;
        const role = document.getElementById('new-user-role')?.value;
        const fileImage = selectedFiles.user.image;

        let avatarUrl = null;
        if (fileImage) avatarUrl = await uploadFile(fileImage);

        const { success, data } = await postAPI('/users/crud_user', {
            action: 'addUser',
            username,
            password,
            email,
            fullName,
            userTag,
            avatarUrl,
            role,
        });

        if (success && data.done) {
            closeModal('modal-add-user');
            selectedFiles.user = { audio: null, image: null };
        }
    } catch (e) {
        console.log(e);
    } finally {
        await loadUserFromAPI();
        renderUsers();
    }

}



// ─── EDIT USER ─────────────────────────────────────────────────────────────
async function openEdirUser(id) {
    const u = DATA.users.find(x => x.id === id);
    if (!u) return;

    // id
    document.getElementById('modal-edit-user').setAttribute('modal-edit-user-id', u.id);

    // img
    const preview = document.getElementById('user-edit-image-preview');
    preview.src = u.avatar_url;
    preview.style.display = 'block';

    // name
    document.getElementById('edit-user-name').value = u.full_name;

    // email
    document.getElementById('edit-user-email').value = u.email;

    // tag
    document.getElementById('edit-user-tag').value = u.taguser;

    // account
    document.getElementById('edit-user-acc').value = u.username;

    // pass 
    document.getElementById('edit-user-name').value = u.full_name;

    // role 
    document.getElementById('edit-user-role').value = u.role;



    openModal('modal-edit-user');
}

async function updateUser() {
    const id = document.getElementById('modal-edit-user').getAttribute('modal-edit-user-id');

    const avatarPreview = document.getElementById('user-edit-image-preview');
    const nameEl = document.getElementById('edit-user-name');
    const emailEl = document.getElementById('edit-user-email');
    const taguserEl = document.getElementById('edit-user-tag');
    const usernameEl = document.getElementById('edit-user-acc');
    const passEl = document.getElementById('edit-user-pass');
    const roleEl = document.getElementById('edit-user-role');

    const { success, data } = await postAPI('/users/crud_user', {
        action: 'updateUser',
        userId: id,
        avatarUrl: avatarPreview.src,
        fullName: nameEl.value,
        email: emailEl.value,
        taguser: taguserEl.value,
        username: usernameEl.value,
        password: passEl.value,
        role: roleEl.value,
    });

    if (success && data.done) {
        showToast('Cập nhật thành công!');
        closeModal('modal-edit-user');

        avatarPreview.src = '';
        avatarPreview.style.display = 'none';
        nameEl.value = '';
        emailEl.value = '';
        taguserEl.value = '';
        usernameEl.value = '';
        passEl.value = '';
        roleEl.value = '';
    } else {
        showToast('❌ Lỗi: ' + data.message);
    }
}



// ─── DELETE USER ─────────────────────────────────────────────────────────────
async function deleteUser(id) {
    if (!confirm('Bạn có chắc muốn ban user này?')) return;

    const { success, data } = await postAPI('/users/crud_user', {
        action: 'deleteUser',
        userId: id,
    });

    if (success && data.done) {
        showToast('✅ Đã thêm bài hát vào album', 'success');
    } else {
        showToast('🚫 User đã bị ban', 'error');
        console.log(data.message);
    }

    await loadUserFromAPI();
    renderUsers();
}
