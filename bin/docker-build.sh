#! /usr/bin/env bash

if git diff-index --quiet HEAD --;
then 
    docker image build -t doppler/laravel-app .
else
    echo '[error]: cannot build Docker image while the working directory is not clean.'
fi
