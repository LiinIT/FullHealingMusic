// HTML Loader - Load các component và page
const HTML_LOADER = {
    cache: {},

    async load(url) {
        if (this.cache[url]) return this.cache[url];

        try {
            const response = await fetch(url);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            const html = await response.text();
            this.cache[url] = html;
            return html;
        } catch (error) {
            console.error(`Error loading ${url}:`, error);
            return `<div class="error">Không thể tải: ${url}</div>`;
        }
    },

    async loadComponent(containerId, componentPath) {
        const container = document.getElementById(containerId);
        if (!container) return;
        const html = await this.load(componentPath);
        container.innerHTML = html;
        return html;
    },

    async loadPage(pageId, pagePath) {
        const container = document.getElementById('page-container');
        if (!container) return;
        const html = await this.load(pagePath);
        container.innerHTML = html;

        // Ẩn tất cả page cũ, chỉ hiển thị page mới
        document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
        const newPage = document.getElementById(`page-${pageId}`);
        if (newPage) newPage.classList.add('active');

        return html;
    },

    async loadAll() {
        await this.loadComponent('sidebar-container', 'components/sidebar.html');
        await this.loadComponent('topbar-container', 'components/topbar.html');
        await this.loadComponent('modals-container', 'components/modals.html');
        await this.loadPage('overview', 'pages/overview.html');
    }
};