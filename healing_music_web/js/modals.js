
// ─── MODAL ───────────────────────────────────────────────────────────────────
function openModal(id) {
    document.getElementById(id)?.classList.add('show');
}
function closeModal(id) {
    document.getElementById(id)?.classList.remove('show');
}

// ─── ARTIST RENDER DROPDOWN MODEL ──────────────────────────────────────────────────────────
function loadOptionArtist(select) {
    select.innerHTML = '<option value="">-- Chọn nghệ sĩ --</option>';
    DATA.artists.forEach(a => {
        const opt = document.createElement('option');
        opt.value = a.id ?? a.artist_id;
        opt.textContent = a.full_name ?? a.name;
        select.appendChild(opt);
    });
}
