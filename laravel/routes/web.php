<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    $config = [
        'APP_DEBUG' => config('doppler.APP_DEBUG'),
        'APP_ENV' => config('doppler.APP_ENV'),
        'APP_KEY' => config('doppler.APP_KEY'),
        'APP_NAME' => config('doppler.APP_NAME'),
        'APP_URL' => config('doppler.APP_URL'),
        'AWS_ACCESS_KEY_ID' => config('doppler.AWS_ACCESS_KEY_ID'),
        'AWS_BUCKET' => config('doppler.AWS_BUCKET'),
        'AWS_DEFAULT_REGION' => config('doppler.AWS_DEFAULT_REGION'),
        'AWS_SECRET_ACCESS_KEY' => config('doppler.AWS_SECRET_ACCESS_KEY'),
        'BROADCAST_DRIVER' => config('doppler.BROADCAST_DRIVER'),
        'CACHE_DRIVER' => config('doppler.CACHE_DRIVER'),
        'DB_CONNECTION' => config('doppler.DB_CONNECTION'),
        'DB_HOST' => config('doppler.DB_HOST'),
        'DB_NAME' => config('doppler.DB_NAME'),
        'DB_PASSWORD' => config('doppler.DB_PASSWORD'),
        'DB_PORT' => config('doppler.DB_PORT'),
        'DB_ROOT_PASSWORD' => config('doppler.DB_ROOT_PASSWORD'),
        'DB_USERNAME' => config('doppler.DB_USERNAME'),
        'DOPPLER_CONFIG' => config('doppler.DOPPLER_CONFIG'),
        'DOPPLER_ENVIRONMENT' => config('doppler.DOPPLER_ENVIRONMENT'),
        'DOPPLER_PROJECT' => config('doppler.DOPPLER_PROJECT'),
        'FILESYSTEM_DRIVER' => config('doppler.FILESYSTEM_DRIVER'),
        'LOG_CHANNEL' => config('doppler.LOG_CHANNEL'),
        'LOG_LEVEL' => config('doppler.LOG_LEVEL'),
        'MAIL_ENCRYPTION' => config('doppler.MAIL_ENCRYPTION'),
        'MAIL_FROM_ADDRESS' => config('doppler.MAIL_FROM_ADDRESS'),
        'MAIL_FROM_NAME' => config('doppler.MAIL_FROM_NAME'),
        'MAIL_HOST' => config('doppler.MAIL_HOST'),
        'MAIL_MAILER' => config('doppler.MAIL_MAILER'),
        'MAIL_PASSWORD' => config('doppler.MAIL_PASSWORD'),
        'MAIL_PORT' => config('doppler.MAIL_PORT'),
        'MAIL_USERNAME' => config('doppler.MAIL_USERNAME'),
        'MEMCACHED_HOST' => config('doppler.MEMCACHED_HOST'),
        'QUEUE_CONNECTION' => config('doppler.QUEUE_CONNECTION'),
        'REDIS_HOST' => config('doppler.REDIS_HOST'),
        'REDIS_PASSWORD' => config('doppler.REDIS_PASSWORD'),
        'REDIS_PORT' => config('doppler.REDIS_PORT'),
        'SESSION_DRIVER' => config('doppler.SESSION_DRIVER'),
        'SESSION_LIFETIME' => config('doppler.SESSION_LIFETIME'),
    ];

    return view('doppler')->withConfig($config);
});
