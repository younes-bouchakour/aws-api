<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;

/**
 * @Route("")
 */
class DefaultController
{
    /**
     * @Route("")
     */
    public function healthcheck()
    {
        return new JsonResponse('ok');
    }
}
