#!/usr/bin/env bash

doppler run  --mount .env -- php artisan serve --host 0.0.0.0 --port 9090
