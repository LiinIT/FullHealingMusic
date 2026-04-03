// Configuration
const CONFIG = {
    API_BASE_URL: 'http://localhost:8080',
    WEB_BASE_URL: 'http://127.0.0.1:5500',  // Live Server URL
    PUBLIC_AUDIO: 'public/audios',
    PUBLIC_IMAGE: 'public/images/song',
    DEFAULT_PAGE: 'overview'
};

// Global variables
let nowPlayingIdx = 0;
let isPlaying = false;
let playerInterval = null;
let progressPct = 38;
let file_song = null;
let file_img = null;
let selectedFiles = {
    create: { audio: null, image: null },
    edit: { audio: null, image: null }
};

// Global DATA object (sẽ được fill từ API)
window.DATA = window.DATA || {
    songs: [],
    artists: [],
    albums: [],
    users: [],
    playlists: [],
    activity: []
};