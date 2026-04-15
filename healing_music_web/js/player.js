// ─── MUSIC PLAYER (HTML5 Audio) ──────────────────────────────────────────────
const PLAYER = (() => {
    let audio = new Audio();
    let sortedSongs = [];
    let currentIdx = 0;
    let isShuffle = false;
    let isRepeat = false;

    function init(songs) {
        if (!songs || songs.length === 0) return;
        sortedSongs = [...songs].sort((a, b) => (b.play_count || 0) - (a.play_count || 0));
        currentIdx = 0;
        _loadTrack(currentIdx, false);

        audio.addEventListener('timeupdate', _onTimeUpdate);
        audio.addEventListener('ended', _onEnded);
        audio.addEventListener('loadedmetadata', _onMetadata);
    }

    function _loadTrack(idx, autoplay) {
        const s = sortedSongs[idx];
        if (!s) return;

        audio.src = s.audio_url || '';
        audio.load();

        const npTitle = document.getElementById('np-title');
        const npArtist = document.getElementById('np-artist');
        const npDuration = document.getElementById('np-duration');
        const npImage = document.getElementById('np-image');
        const fill = document.getElementById('progress-fill');
        const timeEl = document.getElementById('current-time');

        if (npTitle) npTitle.textContent = s.title || '—';
        if (npArtist) npArtist.textContent = s.full_name || '—';
        if (npDuration) npDuration.textContent = formatDuration(s.duration_seconds);
        if (npImage) {
            npImage.src = s.image_url || '';
            npImage.style.display = s.image_url ? 'block' : 'none';
        }
        if (fill) fill.style.width = '0%';
        if (timeEl) timeEl.textContent = '0:00';

        isPlaying = false;
        _updatePlayBtn();

        if (autoplay) play();
    }

    function _onTimeUpdate() {
        if (!audio.duration) return;
        const pct = (audio.currentTime / audio.duration) * 100;
        const fill = document.getElementById('progress-fill');
        const timeEl = document.getElementById('current-time');
        if (fill) fill.style.width = pct + '%';
        if (timeEl) {
            const m = Math.floor(audio.currentTime / 60);
            const s = Math.floor(audio.currentTime % 60);
            timeEl.textContent = `${m}:${s.toString().padStart(2, '0')}`;
        }
    }

    function _onMetadata() {
        const npDuration = document.getElementById('np-duration');
        if (npDuration) npDuration.textContent = formatDuration(Math.floor(audio.duration));
    }

    function _onEnded() {
        if (isRepeat) {
            audio.currentTime = 0;
            audio.play();
        } else {
            next();
        }
    }

    function _updatePlayBtn() {
        const btn = document.getElementById('play-btn');
        if (btn) btn.innerHTML = isPlaying ? ICONS.ui.pause : ICONS.ui.play;
    }

    function play() {
        if (!audio.src) return;
        audio.play().catch(() => {});
        isPlaying = true;
        _updatePlayBtn();
    }

    function pause() {
        audio.pause();
        isPlaying = false;
        _updatePlayBtn();
    }

    function togglePlay() {
        if (isPlaying) pause(); else play();
    }

    function next() {
        if (sortedSongs.length === 0) return;
        if (isShuffle) {
            currentIdx = Math.floor(Math.random() * sortedSongs.length);
        } else {
            currentIdx = (currentIdx + 1) % sortedSongs.length;
        }
        _loadTrack(currentIdx, true);
    }

    function prev() {
        if (sortedSongs.length === 0) return;
        if (audio.currentTime > 3) {
            audio.currentTime = 0;
            return;
        }
        currentIdx = (currentIdx - 1 + sortedSongs.length) % sortedSongs.length;
        _loadTrack(currentIdx, true);
    }

    function seek(event) {
        const bar = event.currentTarget;
        const pct = event.offsetX / bar.offsetWidth;
        if (audio.duration) {
            audio.currentTime = pct * audio.duration;
        }
    }

    function toggleShuffle() {
        isShuffle = !isShuffle;
        const btn = document.getElementById('shuffle-btn');
        if (btn) btn.style.color = isShuffle ? 'var(--primary)' : '';
    }

    function toggleRepeat() {
        isRepeat = !isRepeat;
        const btn = document.getElementById('repeat-btn');
        if (btn) btn.style.color = isRepeat ? 'var(--primary)' : '';
    }

    function playSong(songId) {
        const idx = sortedSongs.findIndex(s => s.song_id === songId);
        if (idx === -1) return;
        currentIdx = idx;
        _loadTrack(currentIdx, true);
    }

    return { init, togglePlay, next, prev, seek, toggleShuffle, toggleRepeat, playSong };
})();

// ─── GLOBAL WRAPPERS (dùng trong onclick) ────────────────────────────────────
function togglePlay()  { PLAYER.togglePlay(); }
function nextTrack()   { PLAYER.next(); }
function prevTrack()   { PLAYER.prev(); }
function seekTrack(e)  { PLAYER.seek(e); }
