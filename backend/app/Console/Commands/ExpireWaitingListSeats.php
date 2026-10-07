<?php

namespace App\Console\Commands;

use App\Services\WaitingListService;
use Illuminate\Console\Command;

class ExpireWaitingListSeats extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'rusl:waiting-list-expire';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Expire unclaimed promoted seats older than 24 hours and auto-promote next queued students';

    /**
     * Execute the console command.
     */
    public function handle(WaitingListService $waitingListService): int
    {
        $this->info('Scanning waiting list queues for expired promotions (>24h)...');

        $expiredCount = $waitingListService->expireStalePromotions();

        $this->info("Successfully processed {$expiredCount} expired queue seat(s). Next eligible candidates notified.");

        return Command::SUCCESS;
    }
}
