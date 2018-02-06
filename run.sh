#!/bin/bash

usage () {
cat <<EOF
Usage: $0 <PROJECT> [TRAINER]

  This will start a showoff composition

  Parameters:
    <PROJECT>   (mandatory) Coursename to load
    [TRAINER]   (optional)  If given, will add the presentation slide present in ../common/Trainers/\${TRAINER}.md
EOF
}

PROJECT="${1%.json}"
TRAINER="${2:-none}"

if [ -z $PROJECT ]; then
  usage
  exit 42
fi

# Setup trainer slide
ln -sf ../common/Trainers/$TRAINER.md Course_Overview/Course_Trainer.md

PROJECT=$PROJECT docker-compose up -d
