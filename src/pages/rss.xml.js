import rss from "@astrojs/rss";
import { getAllPosts, getPostTags } from "../utils/posts";

export async function GET(context) {
  const posts = await getAllPosts();

  return rss({
    title: "Mostly Harmless",
    description: "Mostly Harmless 的个人技术博客。",
    site: context.site,
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate,
      link: `/blog/${post.data.slug}/`,
      categories: getPostTags(post.data.tags)
    })),
    customData: "<language>zh-CN</language>"
  });
}
