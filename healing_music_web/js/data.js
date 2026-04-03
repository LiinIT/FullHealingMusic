// Static data (fallback khi API không có)
const STATIC_DATA = {
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

// Gán vào DATA
DATA.playlists = STATIC_DATA.playlists;
DATA.activity = STATIC_DATA.activity;