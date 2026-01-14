<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('members', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')->constrained()->cascadeOnDelete()->unique();

            // Identity
            $table->string('first_name');
            $table->string('last_name');
            $table->string('gender', 20)->nullable();
            $table->date('birth_date')->nullable();
            $table->string('phone')->nullable();
            $table->string('photo_path')->nullable();

            // Address
            $table->string('address_line')->nullable();
            $table->string('postal_code', 10)->nullable();
            $table->string('city')->nullable();

            // Club / level
            $table->string('club_name')->nullable();
            $table->string('belt')->nullable();
            $table->text('martial_experience')->nullable();

            // Pricing / payments
            $table->string('pricing_tier', 20)->nullable();
            $table->decimal('balance_due', 10, 2)->default(0);
            $table->string('payment_method', 50)->nullable();
            $table->date('payment_date_1')->nullable();
            $table->date('payment_date_2')->nullable();
            $table->date('payment_date_3')->nullable();

            // Legal guardian (minors)
            $table->string('legal_guardian_name')->nullable();
            $table->string('legal_guardian_phone')->nullable();
            $table->string('legal_guardian_email')->nullable();
            $table->boolean('legal_guardian_consent_training')->default(false);

            // Emergency
            $table->string('emergency_contact_name')->nullable();
            $table->string('emergency_contact_email')->nullable();

            // T-shirt
            $table->string('tshirt_size', 20)->nullable();
            $table->string('tshirt_type', 20)->nullable();

            // Health / consents
            $table->boolean('medical_certificate_provided')->default(false);
            $table->boolean('rules_accepted')->default(false);
            $table->boolean('image_consent')->default(false);
            $table->boolean('qs_sport_validated')->default(false);

            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('members');
    }
};
