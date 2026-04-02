// Music Player
function togglePlay() {
    isPlaying = !isPlaying;
    const btn = document.getElementById('play-btn');
    if (btn) btn.innerHTML = isPlaying ? ICONS.ui.pause : ICONS.ui.play;

    if (isPlaying) {
        if (playerInterval) clearInterval(playerInterval);
        playerInterval = setInterval(() => {
            progressPct = (progressPct + 0.2) % 100;
            const fill = document.getElementById('progress-fill');
            const time = document.getElementById('current-time');
            if (fill) fill.style.width = progressPct + '%';
            if (time) {
                const secs = Math.floor(progressPct * 3.52);
                const m = Math.floor(secs / 60);
                const s = secs % 60;
                time.textContent = `${m}:${s.toString().padStart(2, '0')}`;
            }
        }, 200);
    } else {
        if (playerInterval) clearInterval(playerInterval);
        playerInterval = null;
    }
}

function nextTrack() {
    if (DATA.songs.length === 0) return;
    nowPlayingIdx = (nowPlayingIdx + 1) % DATA.songs.length;
    updatePlayer();
}

function prevTrack() {
    if (DATA.songs.length === 0) return;
    nowPlayingIdx = (nowPlayingIdx - 1 + DATA.songs.length) % DATA.songs.length;
    updatePlayer();
}

function updatePlayer() {
    if (DATA.songs.length === 0) return;
    const s = DATA.songs[nowPlayingIdx];
    const title = document.getElementById('np-title');
    const artist = document.getElementById('np-artist');
    if (title) title.textContent = s.title || '';
    if (artist) artist.textContent = s.full_name || '';
    progressPct = 0;
    showToast(`Now Playing: ${s.title}`, 'info');
}