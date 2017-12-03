#!/bin/bash
set -e
source base.sh
# 搜索可以翻译的文件
declare -a files
sources_dir="$(get-lctt-path)"/sources
if [[ $# -eq 0 ]];then
    i=0
    while read -r file;do
        if ! file-translating-p "${file}";then
           printf "%3d. %s\n" $i "${file}"
           files[$i]="${file}"
           i=$((i+1))
        fi
    done< <(find "${sources_dir}" -name "2*.md")
    read -r -p "input the article number you want to translate: " num
    file="${source_dir}"/"${files[$num]}" # 使用绝对路径，否则后面无法cd进入文件所在目录
else
    file="$*"
fi

# 检查指定文件是否可以翻译
if file-translating-p "${file}";then
    warn "${file} is under translating!"
    exit 1
fi

cd "$(dirname "${file}")"
filename=$(basename "${file}")
git_user=$(get-github-user)
new_branch="translate-$(title-to-branch "${filename}")"
git branch "${new_branch}" master
git checkout "${new_branch}"
sed -i "1i translating by ${git_user}" "${filename}"
git add "${filename}"
git commit -m "translating by ${git_user}"
git push -u origin "${new_branch}"
