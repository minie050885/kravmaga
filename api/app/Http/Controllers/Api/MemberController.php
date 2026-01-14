<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class MemberController extends Controller
{
    public function index(): JsonResponse
    {
        $users = User::with('member')->get();

        return response()->json([
            'data' => $users,
        ]);
    }
}
