<?php

declare(strict_types=1);

namespace Modules\User\App\States;

use Spatie\ModelStates\State;
use Spatie\ModelStates\StateConfig;

abstract class UserStatus extends State
{
    public static function config(): StateConfig
    {
        return parent::config()
            ->allowAllTransitions()
            ->ignoreSameState();
    }
}