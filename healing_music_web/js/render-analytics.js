// ─── ANALYTICS PAGE ──────────────────────────────────────────────────────────
// Dùng Chart.js (loaded via CDN in index.html)
// Data source: DATA.songs, DATA.artists, DATA.users (global)

const _anCharts = {}; // track chart instances để destroy trước khi re-render

function _destroyChart(id) {
    if (_anCharts[id]) {
        _anCharts[id].destroy();
        delete _anCharts[id];
    }
}

// Màu sắc theo theme
function _anColors() {
    const style = getComputedStyle(document.documentElement);
    return {
        primary:   style.getPropertyValue('--primary').trim()   || '#FF6B4A',
        secondary: style.getPropertyValue('--secondary').trim() || '#E84393',
        accent:    style.getPropertyValue('--accent').trim()    || '#FFB347',
        success:   style.getPropertyValue('--success').trim()   || '#4ADE80',
        text:      style.getPropertyValue('--text-primary').trim()   || '#F0EEF6',
        muted:     style.getPropertyValue('--text-muted').trim()     || '#5C5A6A',
        secondary2:style.getPropertyValue('--text-secondary').trim() || '#9896A8',
        border:    style.getPropertyValue('--border-soft').trim()    || 'rgba(255,255,255,0.06)',
        cardBg:    style.getPropertyValue('--bg-card2').trim()       || '#1E1E28',
    };
}

function _chartDefaults(c) {
    return {
        color: c.text,
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#16161E',
                titleColor: c.text,
                bodyColor: c.secondary2,
                borderColor: c.border,
                borderWidth: 1,
                padding: 10,
                cornerRadius: 8,
            },
        },
        scales: {
            x: {
                ticks: { color: c.secondary2, font: { size: 11 } },
                grid: { color: c.border },
            },
            y: {
                ticks: { color: c.secondary2, font: { size: 11 } },
                grid: { color: c.border },
            },
        },
    };
}

// ── Nhóm data theo tháng (YYYY-MM) ──
function _groupByMonth(items, dateField, n = 12) {
    const now = new Date();
    const months = [];
    for (let i = n - 1; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        months.push(`${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`);
    }
    const counts = {};
    months.forEach(m => (counts[m] = 0));
    items.forEach(item => {
        const raw = item[dateField];
        if (!raw) return;
        const d = new Date(raw);
        const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
        if (key in counts) counts[key]++;
    });
    return {
        labels: months.map(m => {
            const [y, mo] = m.split('-');
            return `T${parseInt(mo)}/${y.slice(2)}`;
        }),
        data: months.map(m => counts[m]),
    };
}

// ─── MAIN RENDER ─────────────────────────────────────────────────────────────
function renderAnalytics() {
    const songs   = DATA.songs   || [];
    const artists = DATA.artists || [];
    const users   = DATA.users   || [];
    const c = _anColors();

    // ── Stat Cards ──
    const totalPlays = songs.reduce((s, x) => s + (x.play_count || 0), 0);
    const avgPlays   = songs.length ? Math.round(totalPlays / songs.length) : 0;
    const hotSong    = [...songs].sort((a, b) => (b.play_count || 0) - (a.play_count || 0))[0];
    const topArtist  = [...artists].sort((a, b) => (b.follower_count || 0) - (a.follower_count || 0))[0];

    document.getElementById('an-total-plays').textContent    = formatNumber(totalPlays);
    document.getElementById('an-avg-plays').textContent      = formatNumber(avgPlays);
    document.getElementById('an-hot-song').textContent       = hotSong ? hotSong.title : '—';
    document.getElementById('an-hot-song-plays').textContent = hotSong ? `${formatNumber(hotSong.play_count || 0)} plays` : '0 plays';
    document.getElementById('an-top-artist').textContent     = topArtist ? topArtist.full_name : '—';
    document.getElementById('an-top-artist-followers').textContent = topArtist ? `${formatNumber(topArtist.follower_count || 0)} followers` : '0 followers';

    // ── Chart 1: Top 10 Songs (Horizontal Bar) ──
    _destroyChart('top-songs');
    const top10Songs = [...songs]
        .sort((a, b) => (b.play_count || 0) - (a.play_count || 0))
        .slice(0, 10);
    const ctx1 = document.getElementById('chart-top-songs')?.getContext('2d');
    if (ctx1) {
        _anCharts['top-songs'] = new Chart(ctx1, {
            type: 'bar',
            data: {
                labels: top10Songs.map(s => s.title.length > 18 ? s.title.slice(0, 18) + '…' : s.title),
                datasets: [{
                    label: 'Plays',
                    data: top10Songs.map(s => s.play_count || 0),
                    backgroundColor: top10Songs.map((_, i) =>
                        i === 0 ? c.primary : i === 1 ? c.secondary : i === 2 ? c.accent : `rgba(255,107,74,${0.55 - i * 0.04})`
                    ),
                    borderRadius: 6,
                    borderSkipped: false,
                }],
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: _chartDefaults(c).plugins.tooltip,
                },
                scales: {
                    x: { ticks: { color: c.secondary2, font: { size: 11 } }, grid: { color: c.border } },
                    y: { ticks: { color: c.text, font: { size: 11 } }, grid: { display: false } },
                },
            },
        });
    }

    // ── Chart 2: Verified vs Unverified (Doughnut) ──
    _destroyChart('verified');
    const verified   = artists.filter(a => a.is_verified).length;
    const unverified = artists.length - verified;
    const ctx2 = document.getElementById('chart-verified')?.getContext('2d');
    if (ctx2) {
        _anCharts['verified'] = new Chart(ctx2, {
            type: 'doughnut',
            data: {
                labels: ['Verified', 'Unverified'],
                datasets: [{
                    data: [verified, unverified],
                    backgroundColor: [c.primary, c.cardBg],
                    borderColor: [c.primary, c.muted],
                    borderWidth: 2,
                    hoverOffset: 6,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '68%',
                plugins: {
                    legend: { display: false },
                    tooltip: _chartDefaults(c).plugins.tooltip,
                },
            },
        });
    }
    // Legend tự render
    const legend = document.getElementById('an-verified-legend');
    if (legend) {
        legend.innerHTML = `
            <div class="an-legend-item"><span class="an-dot" style="background:${c.primary}"></span>Verified <strong>${verified}</strong></div>
            <div class="an-legend-item"><span class="an-dot" style="background:${c.muted}"></span>Unverified <strong>${unverified}</strong></div>
        `;
    }

    // ── Chart 3: Songs added per month (Line) ──
    _destroyChart('songs-monthly');
    const songsMonthly = _groupByMonth(songs, 'song_created_at', 12);
    const ctx3 = document.getElementById('chart-songs-monthly')?.getContext('2d');
    if (ctx3) {
        _anCharts['songs-monthly'] = new Chart(ctx3, {
            type: 'line',
            data: {
                labels: songsMonthly.labels,
                datasets: [{
                    label: 'Songs Added',
                    data: songsMonthly.data,
                    borderColor: c.primary,
                    backgroundColor: 'rgba(255,107,74,0.12)',
                    pointBackgroundColor: c.primary,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    fill: true,
                    tension: 0.4,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ..._chartDefaults(c),
                plugins: { ..._chartDefaults(c).plugins },
            },
        });
    }

    // ── Chart 4: User signups per month (Line) ──
    _destroyChart('users-monthly');
    const usersMonthly = _groupByMonth(users, 'created_at', 12);
    const ctx4 = document.getElementById('chart-users-monthly')?.getContext('2d');
    if (ctx4) {
        _anCharts['users-monthly'] = new Chart(ctx4, {
            type: 'line',
            data: {
                labels: usersMonthly.labels,
                datasets: [{
                    label: 'New Users',
                    data: usersMonthly.data,
                    borderColor: c.secondary,
                    backgroundColor: 'rgba(232,67,147,0.12)',
                    pointBackgroundColor: c.secondary,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    fill: true,
                    tension: 0.4,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ..._chartDefaults(c),
                plugins: { ..._chartDefaults(c).plugins },
            },
        });
    }

    // ── Chart 5: Top 10 Artists by Followers (Bar) ──
    _destroyChart('top-artists');
    const top10Artists = [...artists]
        .sort((a, b) => (b.follower_count || 0) - (a.follower_count || 0))
        .slice(0, 10);
    const ctx5 = document.getElementById('chart-top-artists')?.getContext('2d');
    if (ctx5) {
        _anCharts['top-artists'] = new Chart(ctx5, {
            type: 'bar',
            data: {
                labels: top10Artists.map(a => a.full_name.length > 14 ? a.full_name.slice(0, 14) + '…' : a.full_name),
                datasets: [{
                    label: 'Followers',
                    data: top10Artists.map(a => a.follower_count || 0),
                    backgroundColor: top10Artists.map((_, i) =>
                        i === 0 ? c.secondary : `rgba(232,67,147,${0.8 - i * 0.06})`
                    ),
                    borderRadius: 6,
                    borderSkipped: false,
                }],
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: _chartDefaults(c).plugins.tooltip,
                },
                scales: {
                    x: { ticks: { color: c.secondary2, font: { size: 11 } }, grid: { color: c.border } },
                    y: { ticks: { color: c.text, font: { size: 11 } }, grid: { display: false } },
                },
            },
        });
    }

    // ── Mini Table: Top songs ──
    const table = document.getElementById('an-songs-table');
    if (table) {
        const rows = [...songs]
            .sort((a, b) => (b.play_count || 0) - (a.play_count || 0))
            .slice(0, 15);
        table.innerHTML = `
            <table class="an-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Bài hát</th>
                        <th>Nghệ sĩ</th>
                        <th>Plays</th>
                    </tr>
                </thead>
                <tbody>
                    ${rows.map((s, i) => `
                        <tr>
                            <td class="an-num">${i + 1}</td>
                            <td class="an-title" title="${escapeHtml(s.title)}">${escapeHtml(s.title.length > 20 ? s.title.slice(0, 20) + '…' : s.title)}</td>
                            <td class="an-artist" title="${escapeHtml(s.full_name || '—')}">${escapeHtml((s.full_name || '—').length > 14 ? (s.full_name || '').slice(0, 14) + '…' : (s.full_name || '—'))}</td>
                            <td class="an-plays">${formatNumber(s.play_count || 0)}</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        `;
    }
}
