#!/bin/zsh

echo -n "输入文章标题 > "
read title

echo -n "输入文件名（不含扩展名） > "
read filename

# 自动生成当前日期，格式：2026-06-06
date=$(date +%Y-%m-%d)

filepath="./src/content/blog/${filename}.md"

# 检查文件是否已存在
if [[ -f "$filepath" ]]; then
    echo "错误：文件 $filepath 已存在"
    exit 1
fi

# 写入 frontmatter
cat > "$filepath" << EOF
---
title: "$title"
description: ""
pubDate: $date
tags: [""]
slug: "$filename"
---
EOF

echo "✅ 已创建：$filepath"
