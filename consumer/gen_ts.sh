#!/bin/sh -e

# This script generates a template spec json file from a template spec template file and a deploy script

# template sepc template file
TEMPLATE_FILE=make_aml_ws_template.json
# template sepc json file
OUTPUT_FILE=make_aml_ws.json

SCRIPT_CONTENT=$(
	awk '
		{
			gsub(/\\/,"\\\\")
			gsub(/"/,"\\\"")
			printf "%s\\\\n", $0
		}
	' deploy.sh
)

awk -v script_content="$SCRIPT_CONTENT" '
	{
		gsub(/SCRIPT_CONTENT/, script_content)
		print
	}
' "$TEMPLATE_FILE" > "$OUTPUT_FILE"
