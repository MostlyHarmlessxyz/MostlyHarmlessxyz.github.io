# 开发与发布指南

## 环境准备

项目使用 Node.js 24。仓库提供 `mise.toml`；安装了 mise 的话，在仓库目录运行：

```bash
mise install
npm ci
```

常用命令：

```bash
npm run dev      # 启动本地开发服务器
npm run lint     # 检查 Astro 内容和类型
npm run build    # 构建静态站点到 dist/
npm run preview  # 预览构建产物
```

## 新建文章

运行交互向导，按提示填写标题和 slug：

```bash
./new.sh
```

也可以直接传入标题、slug 和其他字段：

```bash
./new.sh --date 2026-10-11 \
  --description "文章摘要" \
  --tag "技术" --tag "笔记" \
  -- "文章标题" article-slug
```

使用 `--mdx` 可创建 `.mdx` 文件；默认创建 `.md` 文件。日期默认为今天，摘要和标签可以留空。slug 同时作为文件名和文章 URL，只允许小写英文字母、数字和短横线，例如 `article-slug`。脚本会拒绝无效日期、非法 slug 和已存在的目标文件，不会覆盖已有文章。运行 `./new.sh --help` 查看选项。

脚本生成的 frontmatter 可以按需编辑：

```md
---
title: '文章标题'
description: '文章摘要'
pubDate: 2026-10-11
tags: ['技术', '笔记']
slug: 'article-slug'
---
```

必需字段为 `title`、`description`、`pubDate` 和 `slug`；`tags` 是字符串数组，可以为空。`pubDate` 使用 `YYYY-MM-DD` 格式。文章地址为 `/blog/<slug>/`。

## 写作、预览和附件

文章放在 `src/content/blog/`，正文使用 Markdown；`.mdx` 还支持在 Markdown 中编写 JSX。数学公式支持 LaTeX：行内公式写成 `$E = mc^2$`，块级公式使用一对 `$$`。

图片、PDF 等静态资源放在 `public/`，例如：

```text
public/assets/my-note/figure.png
public/assets/my-note/paper.pdf
```

文章中的引用路径以 `/` 开头：

```md
![配图](/assets/my-note/figure.png)

[下载 PDF](/assets/my-note/paper.pdf)
```

`.tex` 文件可以在本地用 XeLaTeX 编译为 PDF，再放入 `public/`。GitHub Pages 部署流程只构建 Astro 站点，不会运行 XeLaTeX。

启动开发服务器后，打开终端显示的地址（通常是 `http://localhost:4321/`）：

```bash
npm run dev
```

检查首页、文章页 `/blog/<slug>/`、标签页、图片和公式显示。提交前运行：

```bash
npm run lint
npm run build
```

构建产物写入 `dist/`，由 `.gitignore` 忽略，不要提交。

## 提交和发布

开始写作前先进入项目目录并同步 `main`：

```bash
git pull --ff-only
```

完成文章后检查改动，再添加需要提交的文章和资源：

```bash
git status
git diff
git add src/content/blog/article-slug.md public/assets/my-note/
git commit -m "Add blog post: article title"
git push origin main
```

推送到 `main` 会触发 `.github/workflows/pages.yml`，自动安装依赖、检查并构建站点，再部署到 GitHub Pages。Pull request 会执行构建检查，但不会部署。GitHub 仓库的 Pages Source 应设置为 **GitHub Actions**。

## 常见问题

- 新文章没有显示：检查 frontmatter 是否完整，`draft` 是否为 `true`，以及发布日期和 slug 格式。
- 图片或 PDF 打不开：确认文件在 `public/` 下，引用路径以 `/` 开头。
- 公式没有渲染：检查公式分隔符是否成对，块级公式应使用 `$$`。
- 构建失败：本地运行 `npm run lint` 和 `npm run build`，根据报错修复内容或配置。
- 推送失败：先运行 `git pull --ff-only` 同步远端，再重试。
