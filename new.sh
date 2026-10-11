#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
blog_dir="$script_dir/src/content/blog"

usage() {
  cat <<'USAGE'
用法: ./new.sh [选项] [标题 [slug]]

选项:
  --mdx                    创建 .mdx 文件（默认创建 .md）
  --date YYYY-MM-DD        设置发布日期（默认今天）
  --description TEXT       设置文章摘要
  --tag TAG                添加标签，可重复使用
  -h, --help               显示帮助

不提供标题或 slug 时会进入交互提示。slug 也会用作文件名，只允许小写字母、数字和短横线。
USAGE
}

fail() {
  printf '错误：%s\n' "$*" >&2
  exit 1
}

yaml_quote() {
  local value=$1
  local char
  local i

  printf "'"
  for ((i = 0; i < ${#value}; i++)); do
    char=${value:i:1}
    [[ $char == "'" ]] && printf "'"
    printf '%s' "$char"
  done
  printf "'"
}

prompt_value() {
  local prompt=$1
  local variable_name=$2
  local value

  printf '%s' "$prompt" >/dev/tty
  IFS= read -r value </dev/tty || fail '读取输入失败。'
  printf -v "$variable_name" '%s' "$value"
}

valid_date() {
  local value=$1
  local normalized

  [[ $value =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 1

  if normalized=$(date -d "$value" '+%Y-%m-%d' 2>/dev/null); then
    :
  elif normalized=$(date -j -f '%Y-%m-%d' "$value" '+%Y-%m-%d' 2>/dev/null); then
    :
  else
    return 1
  fi

  [[ $normalized == "$value" ]]
}

validate_single_line() {
  local name=$1
  local value=$2

  [[ $value != *$'\n'* && $value != *$'\r'* ]] || fail "$name 不能包含换行符。"
}

trim_tag() {
  local value=$1
  value=${value#"${value%%[![:space:]]*}"}
  value=${value%"${value##*[![:space:]]}"}
  printf '%s' "$value"
}

parse_tag_list() {
  local input=$1
  local tag
  local -a parsed_tags=()

  IFS=',' read -r -a parsed_tags <<< "$input"
  for tag in "${parsed_tags[@]}"; do
    tag=$(trim_tag "$tag")
    [[ -n $tag ]] || fail '标签不能为空；多个标签请用逗号分隔。'
    validate_single_line '标签' "$tag"
    tags+=("$tag")
  done
}

title=
slug=
description=
description_set=false
pub_date=$(date '+%Y-%m-%d')
tags=()
tags_set=false
extension=md
positionals=()

while (($#)); do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    --mdx)
      extension=mdx
      shift
      ;;
    --date)
      (($# >= 2)) || fail '--date 后需要 YYYY-MM-DD 日期。'
      pub_date=$2
      shift 2
      ;;
    --description)
      (($# >= 2)) || fail '--description 后需要摘要文本。'
      description=$2
      description_set=true
      shift 2
      ;;
    --tag)
      (($# >= 2)) || fail '--tag 后需要标签文本。'
      tags+=("$2")
      tags_set=true
      shift 2
      ;;
    --)
      shift
      while (($#)); do
        positionals+=("$1")
        shift
      done
      break
      ;;
    -*)
      fail "未知选项：$1（使用 --help 查看用法）"
      ;;
    *)
      positionals+=("$1")
      shift
      ;;
  esac
done

((${#positionals[@]} <= 2)) || fail '最多可提供标题和 slug 两个位置参数。'
title=${positionals[0]-}
slug=${positionals[1]-}

if [[ -z $title || -z $slug ]]; then
  [[ -r /dev/tty ]] || fail '请提供标题和 slug；非交互用法见 --help。'
  [[ -n $title ]] || prompt_value '文章标题 > ' title
  [[ -n $slug ]] || prompt_value 'slug（同时作为文件名，不含扩展名） > ' slug

  if [[ $description_set == false ]]; then
    prompt_value '文章摘要（可留空） > ' description
  fi
  if [[ $tags_set == false ]]; then
    local_tags=
    prompt_value '标签（逗号分隔，可留空） > ' local_tags
    [[ -z $local_tags ]] || parse_tag_list "$local_tags"
  fi
fi

[[ -n $title && $title =~ [^[:space:]] ]] || fail '标题不能为空。'
[[ $slug =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail 'slug 只允许小写字母、数字和单个短横线分隔的片段。'
valid_date "$pub_date" || fail "无效日期：$pub_date（格式应为 YYYY-MM-DD）。"
validate_single_line '标题' "$title"
validate_single_line '摘要' "$description"

for i in "${!tags[@]}"; do
  tags[$i]=$(trim_tag "${tags[$i]}")
  [[ -n ${tags[$i]} ]] || fail '标签不能为空。'
  validate_single_line '标签' "${tags[$i]}"
done

[[ -d $blog_dir ]] || fail "找不到文章目录：$blog_dir"
target="$blog_dir/$slug.$extension"
[[ ! -e $target && ! -L $target ]] || fail "文件已存在，不会覆盖：$target"
if [[ $extension == md ]]; then
  alternate_target="$blog_dir/$slug.mdx"
else
  alternate_target="$blog_dir/$slug.md"
fi
[[ ! -e $alternate_target && ! -L $alternate_target ]] || fail "slug 已被另一篇文章使用：$alternate_target"

tmp_file=$(mktemp "$blog_dir/.new-post.XXXXXX") || fail '无法创建临时文件。'
cleanup() {
  [[ -z ${tmp_file:-} ]] || rm -f "$tmp_file"
}
trap cleanup EXIT

{
  printf '%s\n' '---'
  printf 'title: '
  yaml_quote "$title"
  printf '\ndescription: '
  yaml_quote "$description"
  printf '\npubDate: %s\n' "$pub_date"
  printf 'tags: ['
  separator=
  for tag in "${tags[@]}"; do
    printf '%s' "$separator"
    yaml_quote "$tag"
    separator=', '
  done
  printf ']\nslug: '
  yaml_quote "$slug"
  printf '\n---\n\n'
} > "$tmp_file"
chmod 644 "$tmp_file"

if ! ln "$tmp_file" "$target" 2>/dev/null; then
  fail "無法建立文章（目標可能已存在）：$target"
fi

rm -f "$tmp_file"
tmp_file=
printf '已创建：%s\n' "$target"
