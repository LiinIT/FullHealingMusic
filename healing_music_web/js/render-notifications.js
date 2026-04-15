// ════════════════ NOTIFICATIONS PAGE ════════════════

const NOTIF_TEMPLATES = {
    new_song: {
        title: '🎵 Bài hát mới đã ra mắt!',
        content: 'Khám phá âm nhạc healing mới nhất vừa được thêm vào Healing Music. Hãy thả lỏng và cảm nhận nhé!',
    },
    new_artist: {
        title: '🎤 Nghệ sĩ mới tham gia!',
        content: 'Một nghệ sĩ healing mới vừa gia nhập cộng đồng. Khám phá âm nhạc của họ ngay hôm nay!',
    },
    healing: {
        title: '🧘 Mẹo healing hôm nay',
        content: 'Dành 10 phút lắng nghe nhạc thiền để giảm stress và tìm lại sự cân bằng. Hãy thử ngay!',
    },
    weekend: {
        title: '🌙 Cuối tuần thư giãn cùng Healing Music',
        content: 'Playlist cuối tuần đặc biệt đang chờ bạn. Để âm nhạc xoa dịu tâm hồn sau một tuần bận rộn.',
    },
};

function applyNotifTemplate(key) {
    const tpl = NOTIF_TEMPLATES[key];
    if (!tpl) return;
    document.getElementById('notif-title').value = tpl.title;
    document.getElementById('notif-content').value = tpl.content;
    updateNotifPreview();
}

function updateNotifPreview() {
    const title = document.getElementById('notif-title')?.value || 'Tiêu đề thông báo';
    const content = document.getElementById('notif-content')?.value || 'Nội dung thông báo sẽ hiển thị ở đây...';
    const imageUrl = document.getElementById('notif-image')?.value || '';

    const titleEl = document.getElementById('preview-title');
    const contentEl = document.getElementById('preview-content');
    const imageWrap = document.getElementById('preview-image-wrap');
    const imageEl = document.getElementById('preview-image');

    if (titleEl) titleEl.textContent = title;
    if (contentEl) contentEl.textContent = content;

    if (imageUrl && imageWrap && imageEl) {
        imageEl.src = imageUrl;
        imageWrap.style.display = 'block';
    } else if (imageWrap) {
        imageWrap.style.display = 'none';
    }

    // Char counts
    const titleCount = document.getElementById('notif-title-count');
    const contentCount = document.getElementById('notif-content-count');
    const titleVal = document.getElementById('notif-title')?.value || '';
    const contentVal = document.getElementById('notif-content')?.value || '';
    if (titleCount) titleCount.textContent = `${titleVal.length}/100`;
    if (contentCount) contentCount.textContent = `${contentVal.length}/300`;
}

function switchNotifTarget(target) {
    document.getElementById('notif-segment-field').style.display =
        target === 'segment' ? 'flex' : 'none';
    document.getElementById('notif-ids-field').style.display =
        target === 'external_ids' ? 'flex' : 'none';

    // Update radio card active state
    ['all', 'segment', 'ids'].forEach(t => {
        const card = document.getElementById(`target-${t}-card`);
        if (card) card.classList.remove('active');
    });
    const activeCard = document.getElementById(`target-${target === 'external_ids' ? 'ids' : target}-card`);
    if (activeCard) activeCard.classList.add('active');
}

async function sendNotification() {
    const title = document.getElementById('notif-title')?.value?.trim();
    const content = document.getElementById('notif-content')?.value?.trim();
    const imageUrl = document.getElementById('notif-image')?.value?.trim();
    const launchUrl = document.getElementById('notif-url')?.value?.trim();
    const target = document.querySelector('input[name="notif-target"]:checked')?.value || 'all';
    const segment = document.getElementById('notif-segment')?.value || 'All';
    const rawIds = document.getElementById('notif-external-ids')?.value || '';

    if (!title) return showToast('Vui lòng nhập tiêu đề', 'error');
    if (!content) return showToast('Vui lòng nhập nội dung', 'error');

    const externalIds = target === 'external_ids'
        ? rawIds.split(/[\n,]+/).map(s => s.trim()).filter(Boolean)
        : [];

    if (target === 'external_ids' && externalIds.length === 0) {
        return showToast('Vui lòng nhập ít nhất 1 User ID', 'error');
    }

    const btn = document.getElementById('notif-send-btn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang gửi...';

    const { success, data } = await postAPI('/notifications', {
        action: 'send',
        title,
        content,
        target,
        segment,
        imageUrl: imageUrl || null,
        launchUrl: launchUrl || null,
        externalIds,
    });

    btn.disabled = false;
    btn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Gửi thông báo';

    if (success && data.done) {
        showToast(`✅ Đã gửi đến ${data.recipients ?? 0} thiết bị`, 'success');
        // Reset form
        document.getElementById('notif-title').value = '';
        document.getElementById('notif-content').value = '';
        document.getElementById('notif-image').value = '';
        document.getElementById('notif-url').value = '';
        document.getElementById('notif-external-ids').value = '';
        updateNotifPreview();
        await loadNotifHistory();
    } else {
        showToast(data?.message || 'Gửi thất bại', 'error');
    }
}

async function loadNotifHistory() {
    const tbody = document.getElementById('notif-history-tbody');
    if (!tbody) return;

    tbody.innerHTML = `<tr><td colspan="5" class="notif-empty">
        <i class="fa-solid fa-spinner fa-spin"></i> Đang tải...
    </td></tr>`;

    const { success, data } = await postAPI('/notifications', { action: 'getHistory' });

    if (!success || !data.notifications) {
        tbody.innerHTML = `<tr><td colspan="5" class="notif-empty">
            <i class="fa-solid fa-triangle-exclamation"></i> Không thể tải lịch sử
        </td></tr>`;
        return;
    }

    const items = data.notifications;

    // Update stats
    const today = new Date().toDateString();
    const todayCount = items.filter(n => new Date(n.sent_at).toDateString() === today).length;
    const totalRecipients = items.reduce((sum, n) => sum + (n.recipients || 0), 0);

    const statTotal = document.getElementById('stat-total');
    const statRecipients = document.getElementById('stat-recipients');
    const statToday = document.getElementById('stat-today');
    if (statTotal) statTotal.textContent = items.length;
    if (statRecipients) statRecipients.textContent = totalRecipients.toLocaleString();
    if (statToday) statToday.textContent = todayCount;

    if (items.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" class="notif-empty">
            <i class="fa-solid fa-bell-slash"></i> Chưa có thông báo nào
        </td></tr>`;
        return;
    }

    PAGINATION.init('notif-history', items, 10, (slice) => {
        tbody.innerHTML = slice.map(n => {
            const targetLabel = _targetLabel(n.target, n.segment);
            const timeStr = _formatNotifTime(n.sent_at);
            return `
                <tr>
                    <td>
                        <div class="notif-row-info">
                            <div class="notif-row-title">${escapeHtml(n.title || '')}</div>
                            <div class="notif-row-content">${escapeHtml(n.content || '')}</div>
                        </div>
                    </td>
                    <td>${targetLabel}</td>
                    <td>
                        <span class="notif-recipients-badge">
                            <i class="fa-solid fa-mobile-screen"></i> ${n.recipients ?? 0}
                        </span>
                    </td>
                    <td>
                        <span class="notif-time">${timeStr}</span>
                    </td>
                    <td>
                        <div class="action-btns">
                            <button class="btn-sm btn-edit"
                                onclick="replayNotif(${n.id})">
                                ${ICONS.ui.edit} Dùng lại
                            </button>
                            <button class="btn-sm btn-del"
                                onclick="deleteNotifHistory(${n.id})">
                                ${ICONS.ui.delete} Xoá
                            </button>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
    }, 'notif-history-pagination');
}

function _targetLabel(target, segment) {
    if (target === 'segment') {
        return `<span class="notif-target-badge segment">${escapeHtml(segment || 'All')}</span>`;
    }
    if (target === 'external_ids') {
        return `<span class="notif-target-badge ids"><i class="fa-solid fa-user-tag"></i> User IDs</span>`;
    }
    return `<span class="notif-target-badge all"><i class="fa-solid fa-users"></i> Tất cả</span>`;
}

function _formatNotifTime(sentAt) {
    try {
        const d = new Date(sentAt);
        const now = new Date();
        const diff = Math.floor((now - d) / 1000);
        if (diff < 60) return 'Vừa xong';
        if (diff < 3600) return `${Math.floor(diff / 60)} phút trước`;
        if (diff < 86400) return `${Math.floor(diff / 3600)} giờ trước`;
        return d.toLocaleDateString('vi-VN', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit',
        });
    } catch (_) {
        return sentAt || '—';
    }
}

// Dùng lại thông báo cũ — điền lại form
async function replayNotif(id) {
    const { success, data } = await postAPI('/notifications', { action: 'getHistory' });
    if (!success) return;
    const item = data.notifications.find(n => n.id === id);
    if (!item) return;

    document.getElementById('notif-title').value = item.title || '';
    document.getElementById('notif-content').value = item.content || '';
    document.getElementById('notif-image').value = item.image_url || '';

    // Set target radio
    const targetVal = item.target || 'all';
    const radio = document.querySelector(`input[name="notif-target"][value="${targetVal}"]`);
    if (radio) { radio.checked = true; switchNotifTarget(targetVal); }

    if (item.segment) document.getElementById('notif-segment').value = item.segment;
    updateNotifPreview();

    // Scroll lên form
    document.getElementById('notif-title').scrollIntoView({ behavior: 'smooth' });
    showToast('Đã điền lại thông báo cũ', 'info');
}

async function deleteNotifHistory(id) {
    if (!confirm('Xoá lịch sử thông báo này?')) return;
    const { success, data } = await postAPI('/notifications', { action: 'deleteHistory', id });
    if (success && data.done) {
        showToast('Đã xoá', 'success');
        await loadNotifHistory();
    } else {
        showToast('Xoá thất bại', 'error');
    }
}

// Gọi khi navigate vào trang
function renderNotifications() {
    updateNotifPreview();
    loadNotifHistory();
}
