// ════════════════ PAGINATION UTILITY ════════════════
// Usage:
//   PAGINATION.init('songs-table', items, 10, (slice) => renderRows(slice));
//   PAGINATION.goTo('songs-table', 2);

const PAGINATION = (() => {
    const _state = {};

    /**
     * Khởi tạo/cập nhật pagination cho một list.
     * @param {string} id        - ID định danh duy nhất (vd: 'songs', 'albums')
     * @param {Array}  items     - Toàn bộ dữ liệu
     * @param {number} pageSize  - Số item mỗi trang
     * @param {Function} renderFn - Nhận mảng items của trang hiện tại, render vào DOM
     * @param {string} paginationContainerId - ID element chứa pagination buttons
     */
    function init(id, items, pageSize, renderFn, paginationContainerId) {
        _state[id] = {
            items,
            pageSize,
            renderFn,
            containerId: paginationContainerId,
            currentPage: 1,
        };
        _render(id);
    }

    function goTo(id, page) {
        const s = _state[id];
        if (!s) return;
        const total = Math.ceil(s.items.length / s.pageSize);
        s.currentPage = Math.max(1, Math.min(page, total));
        _render(id);
    }

    function _render(id) {
        const s = _state[id];
        if (!s) return;

        const { items, pageSize, renderFn, containerId, currentPage } = s;
        const total = Math.ceil(items.length / pageSize) || 1;

        // Slice dữ liệu
        const start = (currentPage - 1) * pageSize;
        const slice = items.slice(start, start + pageSize);
        renderFn(slice);

        // Render pagination buttons
        const container = document.getElementById(containerId);
        if (!container) return;
        container.innerHTML = _buildHTML(id, currentPage, total, items.length);
    }

    function _buildHTML(id, current, total, totalItems) {
        if (total <= 1) return `<span class="pagination-info">${totalItems} items</span>`;

        let html = `<span class="pagination-info">${totalItems} items</span>`;

        // Prev button
        html += `<button class="page-btn" onclick="PAGINATION.goTo('${id}',${current - 1})" ${current === 1 ? 'disabled' : ''}>
            <i class="fa-solid fa-chevron-left"></i>
        </button>`;

        // Page numbers with ellipsis
        const pages = _pageRange(current, total);
        pages.forEach(p => {
            if (p === '...') {
                html += `<span class="page-ellipsis">…</span>`;
            } else {
                html += `<button class="page-btn ${p === current ? 'active' : ''}" onclick="PAGINATION.goTo('${id}',${p})">${p}</button>`;
            }
        });

        // Next button
        html += `<button class="page-btn" onclick="PAGINATION.goTo('${id}',${current + 1})" ${current === total ? 'disabled' : ''}>
            <i class="fa-solid fa-chevron-right"></i>
        </button>`;

        return html;
    }

    // Sinh dãy trang, rút gọn bằng ellipsis khi cần
    function _pageRange(current, total) {
        if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

        const pages = [];
        pages.push(1);
        if (current > 3) pages.push('...');

        const start = Math.max(2, current - 1);
        const end = Math.min(total - 1, current + 1);
        for (let i = start; i <= end; i++) pages.push(i);

        if (current < total - 2) pages.push('...');
        pages.push(total);
        return pages;
    }

    return { init, goTo };
})();
