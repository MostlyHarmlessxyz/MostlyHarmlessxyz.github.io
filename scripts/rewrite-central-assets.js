/* scripts/rewrite-central-assets.js */
'use strict';

const cheerio = require('cheerio');

function normalizeSlash(p) {
    return (p || '').replace(/\\/g, '/');
}

// 匹配集中式 assets 写法：assets/**、./assets/**、../assets/**（以及 Windows 反斜杠的写法）
function matchCentralAssets(src) {
    const s = normalizeSlash(String(src || '').trim());
    const idx = s.toLowerCase().lastIndexOf('assets/');
    return idx >= 0 ? s.slice(idx) : null; // 返回 "assets/xxx.jpg"
}

hexo.extend.filter.register('after_render:html', function (str) {
    if (!str) return str;

    const config = hexo.config || {};
    const root = normalizeSlash(config.root || '/');

    const $ = cheerio.load(str, {
        decodeEntities: false
    });

    $('img').each(function () {
        const raw = $(this).attr('src');
        if (!raw) return;

        const src = normalizeSlash(raw);

        // 跳过外链或已是绝对路径
        if (/^(https?:)?\/\//i.test(src) || /^\s*\//.test(src)) {
            return;
        }

        // 仅处理集中式 assets
        const central = matchCentralAssets(src); // e.g. "assets/3f05....jpg"
        if (!central) return;

        // 你的真实生成目录在 public/_posts/assets/**，因此 URL 需是 /_posts/assets/**
        let mapped = central.replace(/^assets\//i, '_posts/assets/');
        let newSrc = normalizeSlash(root + mapped).replace(/\/{2,}/g, '/');

        // 防止重复改写
        if (!/^\/?_posts\/assets\//i.test(src)) {
            $(this).attr('src', newSrc);
            // 可选日志：构建时在控制台能看到
            if (console && console.info) {
                console.info('[rewrite-central-assets] ' + raw + ' -> ' + newSrc);
            }
        }
    });

    return $.html();
});
