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
    const title = song.title.toLowerCase();
    const artist = song.artist.toLowerCase();

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
    const name = artist.name.toLowerCase();
    if (name.includes('sơn tùng')) return ICONS.artist.star;
    if (name.includes('taylor')) return ICONS.artist.guitar;
    if (name.includes('ed sheeran')) return ICONS.artist.music;
    if (name.includes('maroon')) return ICONS.artist.microphone;
    if (name.includes('bigflo')) return ICONS.artist.microphone;
    if (name.includes('indila')) return ICONS.artist.keyboard;
    return ICONS.artist.default;
}

function getAlbumIcon(album) {
    const name = album.name.toLowerCase();
    if (name.includes('sky tour')) return ICONS.album.tour;
    if (name.includes('drill')) return ICONS.album.drill;
    if (name.includes('reputation')) return ICONS.album.reputation;
    if (name.includes('jordi')) return ICONS.album.jordi;
    return ICONS.album.default;
}

function getPlaylistIcon(playlist) {
    const name = playlist.name.toLowerCase();
    if (name.includes('healing')) return ICONS.playlist.healing;
    if (name.includes('chill')) return ICONS.playlist.chill;
    if (name.includes('collection')) return ICONS.playlist.collection;
    if (name.includes('study') || name.includes('focus')) return ICONS.playlist.study;
    if (name.includes('late night') || name.includes('drive')) return ICONS.playlist.night;
    if (name.includes('k-indie') || name.includes('indie')) return ICONS.playlist.indie;
    return ICONS.playlist.healing;
}

// ─── DATA ───────────────────────────────────────────────────────────────────
const DATA = {
    songs: [],
    artists: [
        { id: 1, name: 'Sơn Tùng M-TP', followers: '148.6K', songs: 34, streams: '1.4B', icon: getArtistIcon({ name: 'Sơn Tùng M-TP' }) },
        { id: 2, name: 'Taylor Swift', followers: '89.2K', songs: 12, streams: '890M', icon: getArtistIcon({ name: 'Taylor Swift' }) },
        { id: 3, name: 'Ed Sheeran', followers: '62.1K', songs: 8, streams: '540M', icon: getArtistIcon({ name: 'Ed Sheeran' }) },
        { id: 4, name: 'Maroon 5', followers: '41.5K', songs: 15, streams: '320M', icon: getArtistIcon({ name: 'Maroon 5' }) },
        { id: 5, name: 'BigFlo & Oli', followers: '28.9K', songs: 21, streams: '210M', icon: getArtistIcon({ name: 'BigFlo & Oli' }) },
        { id: 6, name: 'Indila', followers: '35.4K', songs: 7, streams: '280M', icon: getArtistIcon({ name: 'Indila' }) },
    ],
    albums: [
        { id: 1, name: 'Sky Tour', artist: 'Sơn Tùng M-TP', songs: 10, year: 2019, plays: '5.3M', icon: getAlbumIcon({ name: 'Sky Tour' }) },
        { id: 2, name: 'my drill', artist: 'BigFlo & Oli', songs: 4, year: 2023, plays: '1.2M', icon: getAlbumIcon({ name: 'my drill' }) },
        { id: 3, name: 'Reputation', artist: 'Taylor Swift', songs: 15, year: 2017, plays: '4.1M', icon: getAlbumIcon({ name: 'Reputation' }) },
        { id: 4, name: 'Jordi', artist: 'Maroon 5', songs: 12, year: 2021, plays: '2.9M', icon: getAlbumIcon({ name: 'Jordi' }) },
    ],
    users: [
        { id: 1, name: 'Ngoc Khanh', username: '@liinit', email: 'hongockhanh.it@gmail.com', playlists: 5, favorites: 34, joined: '2024-01-15', status: 'online', initials: 'NK' },
        { id: 2, name: 'Minh Tuan', username: '@mtuan', email: 'mtuan@gmail.com', playlists: 2, favorites: 18, joined: '2024-03-20', status: 'online', initials: 'MT' },
        { id: 3, name: 'Thu Hang', username: '@thuhang', email: 'hang@gmail.com', playlists: 8, favorites: 67, joined: '2024-02-10', status: 'offline', initials: 'TH' },
        { id: 4, name: 'Duc Anh', username: '@ducanh', email: 'ducanh@gmail.com', playlists: 1, favorites: 9, joined: '2024-04-05', status: 'offline', initials: 'DA' },
        { id: 5, name: 'Lan Anh', username: '@lananh', email: 'lan@gmail.com', playlists: 4, favorites: 45, joined: '2024-01-28', status: 'online', initials: 'LA' },
    ],
    playlists: [
        { id: 1, name: 'Nhạc Healing 🌿', user: '@liinit', songs: 12, visibility: 'public', icon: getPlaylistIcon({ name: 'Nhạc Healing' }) },
        { id: 2, name: 'Chill Vibes', user: '@thuhang', songs: 8, visibility: 'public', icon: getPlaylistIcon({ name: 'Chill Vibes' }) },
        { id: 3, name: 'Sơn Tùng Collection', user: '@liinit', songs: 22, visibility: 'private', icon: getPlaylistIcon({ name: 'Sơn Tùng Collection' }) },
        { id: 4, name: 'Study Focus', user: '@mtuan', songs: 15, visibility: 'public', icon: getPlaylistIcon({ name: 'Study Focus' }) },
        { id: 5, name: 'Late Night Drive', user: '@lananh', songs: 10, visibility: 'private', icon: getPlaylistIcon({ name: 'Late Night Drive' }) },
        { id: 6, name: 'K-Indie Mix', user: '@ducanh', songs: 6, visibility: 'public', icon: getPlaylistIcon({ name: 'K-Indie Mix' }) },
    ],
    activity: [
        { text: '<strong>Ngoc Khanh</strong> added <strong>Chạy Ngay Đi</strong> to Favorites', time: '2m ago', color: '#FF6B4A', icon: ICONS.ui.heart },
        { text: 'New user <strong>Duc Anh</strong> registered', time: '8m ago', color: '#4ADE80', icon: ICONS.ui.user },
        { text: '<strong>Thu Hang</strong> created playlist <strong>Chill Vibes</strong>', time: '23m ago', color: '#E84393', icon: ICONS.ui.plus },
        { text: '<strong>Một Năm Mới Bình An</strong> reached 2.8M plays', time: '1h ago', color: '#FFB347', icon: ICONS.ui.celebration },
        { text: '<strong>Taylor Swift</strong> profile updated by admin', time: '2h ago', color: '#9896A8', icon: ICONS.ui.edit },
        { text: 'New album <strong>my drill</strong> indexed successfully', time: '3h ago', color: '#4ADE80', icon: ICONS.ui.check },
    ]
};


// fetch api to dart_frog
const API_BASE_URL = 'http://localhost:8080'; // Mặc định Dart Frog chạy port 8080

// ==================== HELPER FUNCTIONS ====================
async function fetchAPI(endpoint) {
    const url = `${API_BASE_URL}${endpoint}`;
    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    try {
        const response = await fetch(url, defaultOptions);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        return { success: true, data };
    } catch (error) {
        console.error('Fetch error:', error);
        return { success: false, error: error.message };
    }
}
