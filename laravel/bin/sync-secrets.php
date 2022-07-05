<?php

require __DIR__ . '/../vendor/autoload.php';

use GuzzleHttp\Client;

function fetch($dopplerToken = '', $format = '', $project = null, $config = null)
{
    if (strpos($dopplerToken, 'dp.ct') === 0 or strpos($dopplerToken, 'dp.pt') === 0 and ($project == NULL or $config == NULL)) {
        echo ("[error]: \$project and \$config must be set if using a CLI or Personal Token\n");
        exit(1);
    }

    $client = new Client;

    $params = ['format' => $format];
    if (!is_null($project) and !is_null($config)) {
        $params = array_merge($params, ['project' => $project, 'config' => $config]);
    }
    $url = 'https://api.doppler.com/v3/configs/config/secrets/download?' . http_build_query($params);

    try {
        $response = $client->get($url, [
            'auth' => [$dopplerToken, ''],
            'headers' => [
                'User-Agent' => 'doppler-php-sdk',
                'Accept'     => 'application/json',
            ]
        ]);

        return $response->getBody();
    } catch (exception $e) {
        printf("[error]: Doppler API Error %s %s\n", $e->getResponse()->getStatusCode(), $e->getResponse()->getBody());
        exit(1);
    }
}

$formats = ['json', 'env', 'php'];
$args = getopt('f:', ['format:']);
$format = $args['f'] ?? $args['format'] ?? 'env';

if (!in_array($format, $formats)) {
    printf("[error]: invalid format %s. Valid formats are %s\n", $format, implode(', ', $formats));
}

switch ($format) {
    case 'json':
        echo fetch(getenv('DOPPLER_TOKEN'), $format);
        break;
    case 'env':
        echo fetch(getenv('DOPPLER_TOKEN'), $format);
        break;
    case 'php':
        printf("<?php\n\nreturn %s;\n?>\n", var_export((array) json_decode(fetch(getenv('DOPPLER_TOKEN'), 'json')), TRUE));
        break;
}
