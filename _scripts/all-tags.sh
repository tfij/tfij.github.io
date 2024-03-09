#!/bin/bash

# Ustawienie katalogu
postsDirectory="../_posts"

tags_list=""

for file in "$postsDirectory"/*.md; do
    # Check if the file exists
    if [ -f "$file" ]; then
        tags=$(grep -oP '(?<=tags: \[).*(?=\])' "$file" | tr -d ' ' | tr ',' '\n' | sed 's/^ *//;s/ *$//')
        tags_list="$tags_list,$tags"
    fi
done

# Remove any leading commas from the list
tags_list=$(echo "$tags_list" | sed 's/^,//')

# Display the concatenated list of tags
tags=$(echo "$tags_list" | tr ',' '\n' | sort | uniq)
echo All tags: $tags

template=$(<tag-page-template.html)

# Loop through each tag
for tag in $tags; do
    # Create a new file for the tag
    new_file="../tags/$tag.html"

    # Replace the placeholder with the tag value in the template
    new_content="${template/\{\{tag-value\}\}/$tag}"

    # Write the new content to the new file
    echo "$new_content" > "$new_file"
done
