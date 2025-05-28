<?php

use Illuminate\Support\Facades\Route;

Route::prefix('sse')->group(function () {
    Route::get('time', function () {
        return response()->stream(function () {
            while (true) {

                echo "data: " . json_encode([
                        'time' => \Illuminate\Support\Carbon::now()->toDateTimeLocalString(),
                        'event' => 'ServerTimeEvent'
                    ]) . "\n\n";

                ob_flush();
                flush();

                sleep(1);

                if (connection_aborted()) {
                    break;
                }
            }
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
            'X-Accel-Buffering' => 'no'
        ]);
    });
});

Route::get('/{any?}', function () {
    return view('app'); // Главный Blade-шаблон с Vue
})->where('any', '.*');

//Route::get('/config', [\App\Http\Controllers\ReverbAppController::class, 'config'])->name('config');
