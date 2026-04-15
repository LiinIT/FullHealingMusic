// ─── HELPERS ─────────────────────────────────────────────────────────────────
function timeAgo(dateStr) {
    if (!dateStr) return '';
    const diff = Date.now() - new Date(dateStr).getTime();
    const m = Math.floor(diff / 60000);
    if (m < 1) return 'vừa xong';
    if (m < 60) return `${m}m ago`;
    const h = Math.floor(m / 60);
    if (h < 24) return `${h}h ago`;
    const d = Math.floor(h / 24);
    return `${d}d ago`;
}

// ─── RENDER OVERVIEW ─────────────────────────────────────────────────────────
function renderOverview() {
    // ── Stats ──
    let countTotalPlays = 0;
    DATA.songs.forEach(s => countTotalPlays += (s.play_count || 0));
    document.getElementById('total-plays').innerText = formatNumber(countTotalPlays);
    document.getElementById('total-songs-value').innerText = DATA.songs.length;
    document.getElementById('isong-count').innerText = DATA.songs.length;
    document.getElementById('total-artist-value').innerText = DATA.artists.length;
    document.getElementById('iartist-count').innerText = DATA.artists.length;
    document.getElementById('total-user-value').innerText = DATA.users.length;
    document.getElementById('icount-user').innerText = DATA.users.length;

    // ── Top Tracks ──
    _renderTopTracks([...DATA.songs].sort((a, b) => (b.play_count || 0) - (a.play_count || 0)).slice(0, 5));

    // ── Play Count Chart (Top 10 songs) ──
    const chartWrap = document.getElementById('streams-chart');
    if (chartWrap && DATA.songs.length > 0) {
        const top10 = [...DATA.songs]
            .sort((a, b) => (b.play_count || 0) - (a.play_count || 0))
            .slice(0, 10);
        const max = Math.max(...top10.map(s => s.play_count || 0), 1);

        const barsContainer = chartWrap.querySelector('.mini-chart-bars');
        const labelsContainer = chartWrap.querySelector('.mini-chart-labels');

        if (barsContainer) {
            barsContainer.innerHTML = top10.map((s, i) =>
                `<div class="mini-bar"
                    style="height:${(s.play_count || 0) / max * 100}%;background:${i === 0 ? 'var(--gradient)' : 'var(--gradient-soft)'}"
                    title="${escapeHtml(s.title)}: ${formatNumber(s.play_count || 0)} plays">
                </div>`
            ).join('');
        }
        if (labelsContainer) {
            labelsContainer.innerHTML = top10.map(s =>
                `<div class="mini-label" title="${escapeHtml(s.title)}">${escapeHtml(s.title.length > 6 ? s.title.slice(0, 6) + '…' : s.title)}</div>`
            ).join('');
        }
    }

    // ── Now Playing — init player với toàn bộ songs ──
    PLAYER.init(DATA.songs);

    // ── Activity Feed (từ data thật) ──
    const feed = document.getElementById('activity-feed');
    if (feed) {
        const events = [];

        // Bài hát mới thêm
        [...DATA.songs]
            .filter(s => s.song_created_at || s.created_at)
            .sort((a, b) => new Date(b.song_created_at || b.created_at) - new Date(a.song_created_at || a.created_at))
            .slice(0, 4)
            .forEach(s => {
                events.push({
                    text: I18N.t('act.song_added', { title: escapeHtml(s.title), artist: escapeHtml(s.full_name || '—') }),
                    time: timeAgo(s.song_created_at || s.created_at),
                    date: new Date(s.song_created_at || s.created_at),
                    color: '#FF6B4A',
                    icon: ICONS.song.default,
                });
            });

        // User mới đăng ký
        [...DATA.users]
            .filter(u => u.created_at)
            .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
            .slice(0, 4)
            .forEach(u => {
                events.push({
                    text: I18N.t('act.user_signup', { name: escapeHtml(u.username) }),
                    time: timeAgo(u.created_at),
                    date: new Date(u.created_at),
                    color: '#4ADE80',
                    icon: ICONS.ui.user,
                });
            });

        // Sắp xếp theo thời gian mới nhất
        events.sort((a, b) => b.date - a.date);

        if (events.length === 0) {
            feed.innerHTML = `<div style="color:var(--text-muted);font-size:13px;padding:12px 0;">${I18N.t('ov.no_activity')}</div>`;
        } else {
            feed.innerHTML = events.slice(0, 6).map(a => `
                <div class="activity-item">
                    <div class="activity-dot" style="background:${a.color}">${a.icon}</div>
                    <div class="activity-text">${a.text}</div>
                    <div class="activity-time">${a.time}</div>
                </div>
            `).join('');
        }
    }

    // ── Overview Search ──
    const searchInput = document.getElementById('overview-search-input');
    if (searchInput) {
        searchInput.addEventListener('input', e => searchOverview(e.target.value));
    }
}

// ─── OVERVIEW SEARCH (search all via backend ILIKE) ──────────────────────────
let _overviewSearchSeq = 0;

async function searchOverview(q) {
    const query = (q || '').trim();
    const seq = ++_overviewSearchSeq;

    // Reset về mặc định khi xóa query
    if (!query) {
        _renderTopTracks([...DATA.songs].sort((a, b) => (b.play_count || 0) - (a.play_count || 0)).slice(0, 5));
        const artistsCard = document.getElementById('overview-artists-card');
        const usersCard = document.getElementById('overview-users-card');
        if (artistsCard) artistsCard.style.display = 'none';
        if (usersCard) usersCard.style.display = 'none';
        return;
    }

    // Gọi song search + artist search song song
    const [songRes, artistRes] = await Promise.all([
        postAPI('/songs/search', { keyword: query }),
        postAPI('/artists/get_all', { action: 'getAll', keyword: query }),
    ]);

    if (seq !== _overviewSearchSeq) return; // bỏ kết quả cũ

    // ── Songs ──
    const tops = document.getElementById('top-tracks');
    if (tops) {
        const songs = (songRes.success && songRes.data.songs) ? songRes.data.songs : [];
        _renderTopTracks(songs, true);
    }

    // ── Artists ──
    const artistsCard = document.getElementById('overview-artists-card');
    const artistsList = document.getElementById('overview-artists-list');
    if (artistsCard && artistsList) {
        const artists = (artistRes.success && artistRes.data.artists) ? artistRes.data.artists : [];
        if (artists.length > 0) {
            artistsCard.style.display = 'block';
            artistsList.innerHTML = artists.slice(0, 6).map(a => `
                <div class="activity-item">
                    <div class="activity-dot" style="background:var(--secondary)">
                        <i class="fa-solid fa-microphone-lines"></i>
                    </div>
                    <div class="activity-text">
                        <strong>${escapeHtml(a.full_name)}</strong>
                        ${a.is_verified ? ' <i class="fa-solid fa-circle-check" style="color:var(--primary);font-size:11px"></i>' : ''}
                        <div style="font-size:11px;color:var(--text-muted)">${formatNumber(a.follower_count || 0)} followers</div>
                    </div>
                    <div class="activity-time">${a.is_verified ? 'Verified' : ''}</div>
                </div>
            `).join('');
        } else {
            artistsCard.style.display = 'none';
        }
    }

    // ── Users (filter local vì không có endpoint search user) ──
    const usersCard = document.getElementById('overview-users-card');
    const usersList = document.getElementById('overview-users-list');
    if (usersCard && usersList) {
        const q2 = normalizeText(query);
        const users = DATA.users.filter(u =>
            normalizeText(u.username).includes(q2) ||
            normalizeText(u.full_name).includes(q2) ||
            normalizeText(u.email).includes(q2)
        );
        if (users.length > 0) {
            usersCard.style.display = 'block';
            usersList.innerHTML = users.slice(0, 8).map(u => `
                <div class="activity-item">
                    <div class="activity-dot" style="background:var(--primary)">
                        <i class="fa-solid fa-user"></i>
                    </div>
                    <div class="activity-text">
                        <strong>${escapeHtml(u.username)}</strong>
                        ${u.full_name ? ' — ' + escapeHtml(u.full_name) : ''}
                        <div style="font-size:11px;color:var(--text-muted)">${escapeHtml(u.email || '')}</div>
                    </div>
                    <div class="activity-time">${u.role || 'USER'}</div>
                </div>
            `).join('');
        } else {
            usersCard.style.display = 'none';
        }
    }
}

function _renderTopTracks(songs, isSearch = false) {
    const tops = document.getElementById('top-tracks');
    if (!tops) return;
    if (songs.length === 0) {
        tops.innerHTML = `<div style="color:var(--text-muted);font-size:13px;padding:10px 0;">${I18N.t('ov.no_results')}</div>`;
        return;
    }
    tops.innerHTML = songs.map((s, i) => `
        <div class="track-item" style="cursor:pointer" onclick="PLAYER.playSong(${s.song_id})">
            <div class="track-num">${i + 1}</div>
            <img src="${s.image_url || ''}" width="40" height="40" style="border-radius:8px;object-fit:cover;">
            <div class="track-info">
                <div class="track-name">${escapeHtml(s.title)}</div>
                <div class="track-artist">${escapeHtml(s.full_name || '—')}</div>
            </div>
            <div class="track-plays">${formatNumber(s.play_count || 0)} ${I18N.t('ov.plays_unit')}</div>
        </div>
    `).join('');
}
