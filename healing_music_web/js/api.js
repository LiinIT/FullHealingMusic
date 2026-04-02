// API calls
async function fetchAPI(endpoint) {
    const url = `${CONFIG.API_BASE_URL}${endpoint}`;
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

async function loadSongsFromAPI() {
    const result = await fetchAPI('/songs');
    if (result.success && result.data.songs) {
        DATA.songs = result.data.songs;
        return true;
    }
    return false;
}