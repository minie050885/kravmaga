<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MemberController;

Route::get('/members', [MemberController::class, 'index']);
