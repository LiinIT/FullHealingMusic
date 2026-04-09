# Web Flow

## Scope

- Path: `/Users/asliin/Documents/Healing_music/healing_music_web`
- Stack: static web assets

## High-Level Tree

```text
healing_music_web
├── components
├── css
│   ├── base
│   ├── components
│   ├── layout
│   ├── pages
│   └── utils
├── js
├── pages
└── public
    ├── audios
    └── images
```

## Likely Flow

1. Page structure from `pages`
2. Reusable UI parts in `components`
3. Styling layers in `css`
4. Behavior in `js`
5. Static assets in `public`

## Where To Look First

- Layout or page bug: `pages`, `css/layout`, `css/pages`
- Shared style issue: `css/base`, `css/components`, `css/utils`
- Interaction bug: `js`
- Missing image or audio asset: `public`

## Edit Tracking Notes

- Log page-level and asset-level changes in `change-log.md`
