<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RequestApproval extends Model
{
    use HasFactory;

    protected $primaryKey = 'request_approval_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'request_approval_id',
        'request_id',
        'reviewer_user_id',
        'decision',
        'comments',
        'reviewed_at',
    ];

    protected $casts = [
        'reviewed_at' => 'datetime',
    ];

    public function specialRequest(): BelongsTo
    {
        return $this->belongsTo(SpecialRequest::class, 'request_id', 'request_id');
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewer_user_id', 'user_id');
    }
}
