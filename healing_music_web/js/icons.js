// ─── FONT AWESOME ICON MAPPING ──────────────────────────────────────────────
const ICONS = {
    // Songs
    song: {
        default: '<i class="fa-solid fa-music"></i>',
        remix: '<i class="fa-solid fa-music"></i>',
        ballad: '<i class="fa-solid fa-microphone"></i>',
        pop: '<i class="fa-solid fa-radio"></i>',
        rock: '<i class="fa-solid fa-guitar"></i>',
        electronic: '<i class="fa-solid fa-keyboard"></i>',
        hipHop: '<i class="fa-solid fa-microphone-lines"></i>',
        french: '<i class="fa-solid fa-flag"></i>',
        drum: '<i class="fa-solid fa-drum"></i>',
    },
    // Artists
    artist: {
        default: '<i class="fa-solid fa-user"></i>',
        star: '<i class="fa-solid fa-star"></i>',
        guitar: '<i class="fa-solid fa-guitar"></i>',
        music: '<i class="fa-solid fa-music"></i>',
        microphone: '<i class="fa-solid fa-microphone"></i>',
        keyboard: '<i class="fa-solid fa-keyboard"></i>',
    },
    // Albums
    album: {
        default: '<i class="fa-solid fa-compact-disc"></i>',
        tour: '<i class="fa-solid fa-plane"></i>',
        drill: '<i class="fa-solid fa-screwdriver-wrench"></i>',
        reputation: '<i class="fa-solid fa-shield-halved"></i>',
        jordi: '<i class="fa-solid fa-music"></i>',
    },
    // Playlists
    playlist: {
        healing: '<i class="fa-solid fa-leaf"></i>',
        chill: '<i class="fa-solid fa-cloud"></i>',
        collection: '<i class="fa-solid fa-star"></i>',
        study: '<i class="fa-solid fa-book"></i>',
        night: '<i class="fa-solid fa-moon"></i>',
        indie: '<i class="fa-solid fa-guitar"></i>',
    },
    // UI Actions
    ui: {
        search: '<i class="fa-solid fa-magnifying-glass"></i>',
        bell: '<i class="fa-solid fa-bell"></i>',
        moon: '<i class="fa-regular fa-moon"></i>',
        sun: '<i class="fa-solid fa-sun"></i>',
        user: '<i class="fa-solid fa-user"></i>',
        play: '<i class="fa-solid fa-play"></i>',
        pause: '<i class="fa-solid fa-pause"></i>',
        prev: '<i class="fa-solid fa-backward-step"></i>',
        next: '<i class="fa-solid fa-forward-step"></i>',
        shuffle: '<i class="fa-solid fa-shuffle"></i>',
        repeat: '<i class="fa-solid fa-repeat"></i>',
        edit: '<i class="fa-solid fa-pen-to-square"></i>',
        delete: '<i class="fa-solid fa-trash-can"></i>',
        view: '<i class="fa-regular fa-eye"></i>',
        ban: '<i class="fa-solid fa-ban"></i>',
        plus: '<i class="fa-solid fa-plus"></i>',
        heart: '<i class="fa-solid fa-heart"></i>',
        heartEmpty: '<i class="fa-regular fa-heart"></i>',
        celebration: '<i class="fa-solid fa-confetti"></i>',
        chart: '<i class="fa-solid fa-chart-line"></i>',
        users: '<i class="fa-solid fa-users"></i>',
        settings: '<i class="fa-solid fa-gear"></i>',
        analytics: '<i class="fa-solid fa-chart-simple"></i>',
        close: '<i class="fa-solid fa-xmark"></i>',
        check: '<i class="fa-solid fa-check"></i>',
        warning: '<i class="fa-solid fa-triangle-exclamation"></i>',
        info: '<i class="fa-solid fa-circle-info"></i>',
    }
};

// Helper: Get song icon based on title/artist
function getSongIcon(song) {
    const title = (song.title || '').toLowerCase();
    const artist = (song.artist || song.full_name || '').toLowerCase();

    if (title.includes('remix')) return ICONS.song.remix;
    if (title.includes('mới') || title.includes('new')) return ICONS.song.ballad;
    if (artist.includes('taylor') || artist.includes('swift')) return ICONS.song.rock;
    if (artist.includes('maroon')) return ICONS.song.electronic;
    if (artist.includes('ed sheeran')) return ICONS.song.hipHop;
    if (artist.includes('bigflo') || artist.includes('oli')) return ICONS.song.french;
    if (title.includes('trống') || title.includes('drum')) return ICONS.song.drum;

    return ICONS.song.default;
}

function getArtistIcon(artist) {
    const name = (artist.name || '').toLowerCase();
    if (name.includes('sơn tùng')) return ICONS.artist.star;
    if (name.includes('taylor')) return ICONS.artist.guitar;
    if (name.includes('ed sheeran')) return ICONS.artist.music;
    if (name.includes('maroon')) return ICONS.artist.microphone;
    if (name.includes('bigflo')) return ICONS.artist.microphone;
    if (name.includes('indila')) return ICONS.artist.keyboard;
    return ICONS.artist.default;
}

function getAlbumIcon(album) {
    const name = (album.name || '').toLowerCase();
    if (name.includes('sky tour')) return ICONS.album.tour;
    if (name.includes('drill')) return ICONS.album.drill;
    if (name.includes('reputation')) return ICONS.album.reputation;
    if (name.includes('jordi')) return ICONS.album.jordi;
    return ICONS.album.default;
}

function getPlaylistIcon(playlist) {
    const name = (playlist.name || '').toLowerCase();
    if (name.includes('healing')) return ICONS.playlist.healing;
    if (name.includes('chill')) return ICONS.playlist.chill;
    if (name.includes('collection')) return ICONS.playlist.collection;
    if (name.includes('study') || name.includes('focus')) return ICONS.playlist.study;
    if (name.includes('late night') || name.includes('drive')) return ICONS.playlist.night;
    if (name.includes('k-indie') || name.includes('indie')) return ICONS.playlist.indie;
    return ICONS.playlist.healing;
}