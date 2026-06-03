## 本地开发

建议使用 Node.js 22 或更高版本。本仓库包含 `mise.toml`，如果本机安装了 mise，可以在仓库目录运行：

```bash
mise install
```

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

## 从写文章到发布的完整流程

下面是一篇文章从本地写作、检查、提交、推送，到 GitHub Actions 自动部署到 GitHub Pages 的完整操作。

### 1. 更新本地仓库

开始写作前先进入项目目录，并同步远端最新代码：

```bash
cd /Users/mostly_harmless/Desktop/Blog
git pull --ff-only
```

如果本机使用 mise 管理 Node.js，先确保 Node.js 版本就绪：

```bash
mise install
```

安装依赖：

```bash
npm ci
```

### 2. 创建文章文件

在 `src/content/blog/` 下创建一个 Markdown 或 MDX 文件。文件名建议和文章 slug 一致：

```bash
touch src/content/blog/my-paper-note.md
```

文章开头必须写 frontmatter：

```md
---
title: "我的论文笔记标题"
description: "一句话摘要，显示在首页、文章列表和 SEO 描述中。"
pubDate: 2026-06-03
tags: ["论文", "技术笔记", "研究"]
slug: "my-paper-note"
---
```

字段说明：

- `title`：文章标题。
- `description`：文章摘要，用于列表页、RSS 和 SEO。
- `pubDate`：发布日期，格式为 `YYYY-MM-DD`。
- `tags`：标签数组，会自动生成标签页。
- `slug`：文章 URL，例如 `my-paper-note` 会生成 `/blog/my-paper-note/`。

`slug` 只使用小写字母、数字和短横线，例如 `github-pages-actions`。不要使用空格、中文、斜杠或特殊符号。

### 3. 写正文、公式和附件

正文直接使用 Markdown：

```md
## 摘要

这里写论文或文章摘要。

## 方法

行内公式：$E = mc^2$。

独立公式：

$$
\int_a^b f(x)\,dx = F(b) - F(a)
$$
```

图片、PDF 或其他静态附件放到 `public/` 下。例如：

```text
public/assets/my-paper/figure-1.png
public/assets/my-paper/paper.pdf
```

在文章中引用：

```md
![Figure 1](/assets/my-paper/figure-1.png)

[下载 PDF](/assets/my-paper/paper.pdf)
```

如果你有 `.tex` 文件，推荐在本地用 XeLaTeX 编译成 PDF，再把 PDF 放进 `public/assets/...`：

```bash
xelatex paper.tex
```

博客本身是静态站点，不会在 GitHub Pages 服务器上运行 XeLaTeX；GitHub Actions 只负责构建 Astro 静态页面。

### 4. 本地预览

写完后先启动开发服务器：

```bash
npm run dev
```

打开终端输出的本地地址，通常是：

```text
http://localhost:4321/
```

重点检查：

- 首页是否出现新文章。
- `/blog/你的-slug/` 是否能打开。
- 标签页是否能打开。
- 图片、PDF、公式是否正常显示。
- 浅色/深色模式下阅读是否正常。

### 5. 本地检查和构建

提交前必须跑检查：

```bash
npm run lint
npm run build
```

`npm run lint` 会执行 Astro 类型和内容检查。`npm run build` 会生成静态站点到 `dist/`。

`dist/` 是构建产物，不要提交到 git；它已经在 `.gitignore` 中忽略。真正上线的 `dist/` 会由 GitHub Actions 在云端重新构建并上传到 GitHub Pages。

### 6. 查看改动

提交前查看当前变更：

```bash
git status
git diff
```

确认只包含你本次新增或修改的文章、图片、附件和必要配置。

### 7. 提交到 git

添加文件并提交：

```bash
git add src/content/blog/my-paper-note.md public/assets/my-paper/
git commit -m "Add paper note about my topic"
```

如果只新增一篇文章，提交信息可以写：

```bash
git commit -m "Add blog post: my paper note"
```

### 8. 推送到 GitHub

推送到 `main` 分支：

```bash
git push origin main
```

推送成功后，GitHub 会自动触发 `.github/workflows/pages.yml`。




### 常见问题

- 页面没有样式：检查 `src/layouts/BaseLayout.astro` 是否导入了 `../styles/global.css`，并确认线上 HTML 中有 `/_astro/*.css`。
- 新文章不显示：检查 frontmatter 是否完整，`draft` 是否被设置为 `true`，以及 `pubDate` 是否格式正确。
- 构建失败：先本地运行 `npm run lint` 和 `npm run build`，按错误提示修正文档或配置。
- 图片打不开：确认文件在 `public/` 下，引用路径以 `/` 开头，例如 `/assets/my-paper/figure-1.png`。
- 公式不渲染：确认公式语法完整，块级公式使用成对的 `$$`。
- 推送失败：先运行 `git pull --ff-only` 同步远端，再重新 push。

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
