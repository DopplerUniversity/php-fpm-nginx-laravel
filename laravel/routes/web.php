<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    $config = [
        'APP_NAME' => config('doppler.APP_NAME'),
        'APP_ENV' => config('doppler.APP_ENV'),
        'APP_DEBUG' => config('doppler.APP_DEBUG'),
        'BROADCAST_DRIVER' => config('doppler.BROADCAST_DRIVER'),
        'CACHE_DRIVER' => config('doppler.CACHE_DRIVER'),
        'DB_CONNECTION' => config('doppler.DB_CONNECTION'),
        'LOG_CHANNEL' => config('doppler.LOG_CHANNEL'),
        'DB_CONNECTION' => config('doppler.DB_CONNECTION'),
        'LOG_LEVEL' => config('doppler.LOG_LEVEL'),
        'PUSHER_APP_ID' => gettype(config('doppler.PUSHER_APP_ID')),
        'MAIL_FROM_ADDRESS' => config('doppler.MAIL_FROM_ADDRESS'),
        'MAIL_FROM_NAME' => config('doppler.MAIL_FROM_NAME'),
        'QUEUE_CONNECTION' => config('doppler.QUEUE_CONNECTION'),
        'SESSION_DRIVER' => config('doppler.SESSION_DRIVER'),
        'SESSION_LIFETIME' => config('doppler.SESSION_LIFETIME'),
        'DOPPLER_CONFIG' => config('doppler.DOPPLER_CONFIG', null),
        'DOPPLER_ENVIRONMENT' => config('doppler.DOPPLER_ENVIRONMENT', null),
        'DOPPLER_PROJECT' => config('doppler.DOPPLER_PROJECT', null),
    ];

    return view('doppler')->withConfig($config);
});
