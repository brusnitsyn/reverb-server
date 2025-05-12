<?php

use App\Http\Controllers\ReverbAppController;
use App\Models\ReverbApp;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('reverb-apps')->group(function () {
    Route::get('/', [ReverbAppController::class, 'index']);
    Route::post('/', [ReverbAppController::class, 'store']);
});
