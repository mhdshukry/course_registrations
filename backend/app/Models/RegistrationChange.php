<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RegistrationChange extends Model
{
    use HasFactory;

    protected $primaryKey = 'change_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'change_id',
        'registration_id',
        'changed_by_user_id',
        'previous_value',
        'new_value',
        'reason',
        'changed_at',
    ];

    protected $casts = [
        'changed_at' => 'datetime',
    ];

    public function registration(): BelongsTo
    {
        return $this->belongsTo(Registration::class, 'registration_id', 'registration_id');
    }

    public function changedByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'changed_by_user_id', 'user_id');
    }
}
