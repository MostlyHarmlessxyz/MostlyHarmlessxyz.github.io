---
title: "技术笔记：GitHub Pages + Actions 部署流程"
description: "梳理这个博客如何通过 GitHub Actions 构建并发布到 GitHub Pages。"
pubDate: 2026-06-03
tags: ["GitHub Pages", "CI/CD", "Astro"]
slug: "github-pages-actions"
---

这个博客没有把 `dist/` 构建产物提交到 `main` 分支，而是把发布流程交给 GitHub Actions。这样主分支只保留源码、文章和配置，部署结果由 CI 生成。

一次完整发布包含四个阶段：

1. `actions/checkout` 拉取源码。
2. `npm ci` 根据 `package-lock.json` 安装确定版本的依赖。
3. `npm run lint` 和 `npm run build` 执行类型检查与静态站点构建。
4. `actions/upload-pages-artifact` 上传 `dist/`，再由 `actions/deploy-pages` 发布。

`pull_request` 事件只执行构建检查，不会发布；`push` 到 `main` 和手动触发 `workflow_dispatch` 才会进入部署 job。

GitHub Pages 的 Source 需要配置为 GitHub Actions。这样 Pages 会接收 workflow 上传的 artifact，而不是直接从某个分支目录读取文件。

如果要新增文章，只需要在 `src/content/blog/` 下添加 Markdown 或 MDX 文件，并在 frontmatter 中填写标题、描述、发布时间、标签和 slug。
