#!/bin/bash
set -e # Immediately exit if command fails
set -x # Print each command before running

# Base variables
IMAGE_NAME="docker.io/phamofanthony/learning"
TAG="latest"

# Create container from a base image (can also use scratch)
CONTAINER="$(buildah from python:3.9-slim)"

# Set the working directory
buildah config --workingdir /app "$CONTAINER"

# Add relevant files to container
buildah add "$CONTAINER" ./app.py .
buildah add "$CONTAINER" ./requirements.txt

# Install required packages
buildah run "$CONTAINER" pip install -r requirements.txt

# Set the command to run when the container starts
buildah config --cmd "python app.py" "$CONTAINER"

# Commit the container to create the image
buildah commit "$CONTAINER" "$IMAGE_NAME:$TAG"

# Disable exit on command fail for Trivy scan 
set +e 

# Run a Trivy scan on the image
trivy image --exit-code 1 "$IMAGE_NAME:$TAG"

# If the Trivy scan failed (non-zero exit), don't push the image
if  [ $? -ne 0 ] 
then
	echo "Vulnerabilities were found, halting image push"
	read -p 'Still push? (y/n): ' overrideVar
	if [ "$overrideVar" = "y" ]
	then
		echo "Pushing image"
		buildah push "$IMAGE_NAME:$TAG"
	elif [ "$overrideVar" = "n" ]
	then
		echo "Aborting push"
		exit 1
	else
		echo "Invalid response, aborting push"
		exit 1
	fi
else
	echo "No vulnerabilities found, pushing image"
	buildah push "$IMAGE_NAME:$TAG"
fi
