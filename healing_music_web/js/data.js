// Static data (fallback khi API không có)
const STATIC_DATA = {
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

// Gán vào DATA
DATA.artists = STATIC_DATA.artists;
DATA.albums = STATIC_DATA.albums;
DATA.users = STATIC_DATA.users;
DATA.playlists = STATIC_DATA.playlists;
DATA.activity = STATIC_DATA.activity;