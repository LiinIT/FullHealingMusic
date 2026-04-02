// Configuration
const CONFIG = {
    API_BASE_URL: 'http://localhost:8080',
    DEFAULT_PAGE: 'overview'
};

// Global variables
let nowPlayingIdx = 0;
let isPlaying = false;
let playerInterval = null;
let progressPct = 38;

// Global DATA object (sẽ được fill từ API)
window.DATA = window.DATA || {
    songs: [],
    artists: [],
    albums: [],
    users: [],
    playlists: [],
    activity: []
};