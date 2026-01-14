<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Member;

class ImportMembersFromCsv extends Command
{
    protected $signature = 'import:members {file=users_clean.csv}';
    protected $description = 'Import members and users from a CSV file';

    public function handle(): int
    {
        $file = $this->argument('file');
        $path = storage_path('app/imports/' . $file);

        if (!is_file($path)) {
            $this->error('CSV file not found: ' . $path);
            return Command::FAILURE;
        }

        $content = file_get_contents($path);

        $lines = array_map('str_getcsv', explode("\n", $content), array_fill(0, 1000, ';'));

        $headers = array_map('trim', array_shift($lines));

        $createdUsers = 0;
        $createdMembers = 0;

        foreach ($lines as $index => $line) {
            if (count($line) < count($headers)) {
                continue;
            }

            $data = array_combine($headers, $line);

            if (empty($data['email'])) {
                continue;
            }

            // 1️⃣ USER
            $user = User::where('email', $data['email'])->first();

            if (!$user) {
                $user = User::create([
                    'name' => trim(($data['first_name'] ?? '') . ' ' . ($data['last_name'] ?? '')),
                    'email' => $data['email'],
                    'password' => Hash::make(bin2hex(random_bytes(16))),
                    'role' => $data['role'] ?? 'member',
                    'is_active' => (int)($data['is_active'] ?? 1),
                    'must_set_password' => true,
                ]);


                $createdUsers++;
            }

            // 2️⃣ MEMBER (toujours créé depuis le CSV)
            if (!$user->member) {
                $member = new Member();
                $member->user_id = $user->id;

                $member->first_name = $data['first_name'] ?? null;
                $member->last_name = $data['last_name'] ?? null;
                $member->gender = $data['gender'] ?? null;
                $member->birth_date = $data['birth_date'] ?: null;
                $member->phone = $data['phone'] ?? null;

                $member->address_line = $data['address_line'] ?? null;
                $member->postal_code = $data['postal_code'] ?? null;
                $member->city = $data['city'] ?? null;

                $member->club_name = $data['club_name'] ?? null;
                $member->belt = $data['belt'] ?? null;
                $member->martial_experience = $data['martial_experience'] ?? null;

                $member->pricing_tier = $data['pricing_tier'] ?? null;
                $member->balance_due = $data['balance_due'] ?? 0;
                $member->payment_method = $data['payment_method'] ?? null;
                $member->payment_date_1 = $data['payment_date_1'] ?: null;
                $member->payment_date_2 = $data['payment_date_2'] ?: null;
                $member->payment_date_3 = $data['payment_date_3'] ?: null;

                $member->legal_guardian_name = $data['legal_guardian_name'] ?? null;
                $member->legal_guardian_phone = $data['legal_guardian_phone'] ?? null;
                $member->legal_guardian_email = $data['legal_guardian_email'] ?? null;
                $member->legal_guardian_consent_training = (int)($data['legal_guardian_consent_training'] ?? 0);

                $member->emergency_contact_name = $data['emergency_contact_name'] ?? null;
                $member->emergency_contact_phone = $data['emergency_contact_phone'] ?? null;

                $member->tshirt_size = $data['tshirt_size'] ?? null;
                $member->tshirt_type = $data['tshirt_type'] ?? null;

                $member->medical_certificate_provided = (int)($data['medical_certificate_provided'] ?? 0);
                $member->rules_accepted = (int)($data['rules_accepted'] ?? 0);
                $member->image_consent = (int)($data['image_consent'] ?? 0);
                $member->qs_sport_validated = (int)($data['qs_sport_validated'] ?? 0);

                $member->save();

                $createdMembers++;
            }
        }

        $this->info("Import finished.");
        $this->info("Users created: {$createdUsers}");
        $this->info("Members created: {$createdMembers}");

        return Command::SUCCESS;
    }
}
