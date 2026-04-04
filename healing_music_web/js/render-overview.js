// Render Overview page
function renderOverview() {
    document.getElementById('total-songs-value').innerText = DATA.songs.length;
    document.getElementById('isong-count').innerText = DATA.songs.length;
    document.getElementById('total-artist-value').innerText = DATA.artists.length;
    document.getElementById('iartist-count').innerText = DATA.artists.length;


    // Activity feed
    const feed = document.getElementById('activity-feed');
    if (feed) {
        feed.innerHTML = DATA.activity.map(a => `
            <div class="activity-item">
                <div class="activity-dot" style="background:${a.color}">
                    ${a.icon || ''}
                </div>
                <div class="activity-text">${a.text}</div>
                <div class="activity-time">${a.time}</div>
            </div>
        `).join('');
    }

    // Top tracks
    const tops = document.getElementById('top-tracks');

    if (tops && DATA.songs.length > 0) {

        tops.innerHTML = DATA.songs
            .sort((a, b) => b.play_count - a.play_count)
            .slice(0, 5).map((s, i) => {
                return `<div class="track-item">
                <div class="track-num">${i + 1}</div>
                <img src="${s.image_url || ''}" width="40" height="40" style="border-radius: 8px;">
                <div class="track-info">
                    <div class="track-name">${escapeHtml(s.title)}</div>
                    <div class="track-artist">${escapeHtml(s.full_name)} 
                        <div class="track-plays">${formatDuration(s.duration_seconds)}</div>
                    </div>
                </div>
                <div class="track-plays">${formatNumber(s.play_count)} plays</div>
            </div>`;
            }).join('');
    }

    // Mini chart bars
    const chartWrap = document.getElementById('streams-chart');
    if (chartWrap) {
        const vals = [35, 52, 41, 68, 55, 73, 60, 82, 70, 90, 78, 95];
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const max = Math.max(...vals);
        const barsContainer = chartWrap.querySelector('.mini-chart-bars');
        const labelsContainer = chartWrap.querySelector('.mini-chart-labels');

        if (barsContainer) {
            barsContainer.innerHTML = vals.map((v, i) =>
                `<div class="mini-bar" style="height:${v / max * 100}%;background:${i === 11 ? 'var(--gradient)' : 'var(--gradient-soft)'}" title="${months[i]}: ${v}K streams"></div>`
            ).join('');
        }
        if (labelsContainer) {
            labelsContainer.innerHTML = months.map(m => `<div class="mini-label">${m}</div>`).join('');
        }
    }
}