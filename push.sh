#!/bin/bash

# Build the project.
hugo 

# Go To Public folder
cd public
# Add changes to git.
git add .

# Commit changes.
msg="Pushing new content to the site at $(date +%F-%T)"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ..
