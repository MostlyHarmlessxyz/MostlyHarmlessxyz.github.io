# Mostly Harmless Blog

这是 `MostlyHarmlessxyz.github.io` 的个人技术博客源码。站点使用 Astro、Markdown/MDX 内容集合和 GitHub Actions 构建，并部署到 GitHub Pages。

## 本地开发

```bash
npm ci
npm run dev
npm run lint
npm run build
npm run preview
```

`npm run dev` 会启动本地开发服务器，`npm run build` 会把静态产物输出到 `dist/`。`dist/` 不提交到 `main` 分支。

## 新增文章

在 `src/content/blog/` 下新建 `.md` 或 `.mdx` 文件，并添加 frontmatter：

```md
---
title: "文章标题"
description: "文章摘要"
pubDate: 2026-06-03
tags: ["标签"]
slug: "article-slug"
---
```

文章地址会是 `/blog/article-slug/`。`slug` 只使用小写字母、数字和短横线，便于生成稳定链接。

Markdown 支持 LaTeX 数学公式，例如 `$E = mc^2$` 和 `$$...$$`。如果需要把 `.tex` 文件编译为 PDF，建议在本地使用 XeLaTeX 生成后再把 PDF 作为静态资源放入 `public/`。

## 部署

推送到 `main` 分支会自动触发 `.github/workflows/pages.yml`：

1. 安装 npm 依赖。
2. 执行 `npm run lint`。
3. 执行 `npm run build`。
4. 上传 `dist/` 为 GitHub Pages artifact。
5. 使用 `actions/deploy-pages` 发布到 GitHub Pages。

Pull request 只执行构建检查，不部署。也可以在 GitHub Actions 页面手动运行 `Deploy to GitHub Pages` workflow。

## GitHub Pages 配置

仓库的 Pages Source 应设置为 **GitHub Actions**。当前项目的部署 workflow 使用官方 Actions：`actions/configure-pages`、`actions/upload-pages-artifact` 和 `actions/deploy-pages`。

部署完成后，站点地址为：

https://mostlyharmlessxyz.github.io/
