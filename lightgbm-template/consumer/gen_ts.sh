#!/bin/sh -e

# This script generates a template spec json file from a template spec template file and a deploy script

# template sepc template file
TEMPLATE_FILE=make_aml_ws_template.json
# template sepc json file
OUTPUT_FILE=make_aml_ws.json

SCRIPT_CONTENT=$(cat deploy.sh | sed -z 's/\n/\\\\n/g' | sed -z 's/"/\\\"/g')

sed "s!SCRIPT_CONTENT!${SCRIPT_CONTENT}!" $TEMPLATE_FILE > $OUTPUT_FILE
