# Mostly Harmless Blog

`MostlyHarmlessxyz.github.io` 的个人博客源码。站点使用 Astro、Markdown/MDX 和 GitHub Actions，部署到 GitHub Pages。

## 本地开发

项目使用 Node.js 24。使用 mise 管理 Node 的话，先运行 `mise install`。然后安装依赖并启动开发服务器：

```bash
npm ci
npm run dev
```

## 新建文章

运行 `./new.sh` 按提示创建文章，或运行 `./new.sh --help` 查看命令行选项。新文章保存在 `src/content/blog/`。

完整的写作、预览、检查和发布流程见[开发与发布指南](guide.md)。
