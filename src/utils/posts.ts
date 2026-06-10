import { getCollection, type CollectionEntry } from "astro:content";

export type BlogPost = CollectionEntry<"blog">;

export async function getAllPosts() {
  const posts = await getCollection("blog", ({ data }) => !data.draft);
  return posts.sort(
    (a, b) => b.data.pubDate.getTime() - a.data.pubDate.getTime()
  );
}

export function getAllTags(posts: BlogPost[]) {
  const counts = new Map<string, number>();
  for (const post of posts) {
    for (const tag of getPostTags(post.data.tags)) {
      counts.set(tag, (counts.get(tag) ?? 0) + 1);
    }
  }
  return [...counts.entries()]
    .map(([name, count]) => ({ name, count, slug: slugifyTag(name) }))
    .sort((a, b) => a.name.localeCompare(b.name, "zh-CN"));
}

export function getPostTags(tags: string[]) {
  return tags.map((tag) => tag.trim()).filter((tag) => slugifyTag(tag));
}

export function slugifyTag(tag: string) {
  return tag
    .trim()
    .toLowerCase()
    .replace(/[\/\\]+/g, "-")
    .replace(/\s+/g, "-");
}

export function tagHref(tag: string) {
  return encodeURIComponent(slugifyTag(tag));
}

export function formatDate(date: Date) {
  return new Intl.DateTimeFormat("zh-CN", {
    year: "numeric",
    month: "long",
    day: "numeric"
  }).format(date);
}
