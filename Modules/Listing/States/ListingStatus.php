<?php

declare(strict_types=1);

namespace Modules\Listing\States;

use Spatie\ModelStates\State;
use Spatie\ModelStates\StateConfig;

abstract class ListingStatus extends State
{
    public static function config(): StateConfig
    {
        return parent::config()
            ->default(ActiveListingStatus::class)
            ->allowAllTransitions()
            ->ignoreSameState();
    }
}